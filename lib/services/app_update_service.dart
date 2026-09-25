import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import '../widgets/update_ready_dialog.dart';

/// Google Play in-app updates (flexible flow).
///
/// * Once per launch, shortly after startup, asks Google Play whether a
///   newer version exists. If so, Play shows its own update prompt
///   (Update / No thanks); the user keeps playing while it downloads.
/// * When the download finishes, an in-app dialog offers RESTART (installs
///   via Google Play and relaunches) or LATER.
/// * On every return to the foreground, a finished-but-not-installed
///   download re-offers the restart (never two dialogs at once).
///
/// Everything is non-blocking and silent on failure: debug builds,
/// sideloaded APKs, no Play Store, no network or any Play error simply
/// leave the game running as usual. App data is never touched.
class AppUpdateService with WidgetsBindingObserver {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  /// Root navigator, used to show the "update downloaded" dialog.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _started = false;
  bool _checking = false;
  bool _updateInProgress = false;
  bool _updateOffered = false;
  bool _readyToInstall = false;
  bool _dialogOpen = false;

  /// In-app updates only exist for Play-installed Android release builds.
  bool get _supported => !kIsWeb && !kDebugMode && Platform.isAndroid;

  /// Starts the service once per launch; the first check runs after
  /// [delay] so it never competes with app startup.
  void start({Duration delay = const Duration(seconds: 4)}) {
    if (_started || !_supported) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    Future<void>.delayed(delay, checkForUpdate);
  }

  /// Asks Google Play for update status. Offers the flexible update at
  /// most once per launch, or re-offers installing an already downloaded
  /// update.
  Future<void> checkForUpdate() async {
    if (!_supported || _checking || _updateInProgress) return;
    _checking = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.installStatus == InstallStatus.downloaded) {
        _readyToInstall = true;
        _offerInstall();
      } else if (!_updateOffered &&
          info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.flexibleUpdateAllowed) {
        _updateOffered = true;
        unawaited(startFlexibleUpdate());
      }
    } catch (e) {
      debugPrint('AppUpdateService: update check skipped ($e)');
    } finally {
      _checking = false;
    }
  }

  /// Shows Google Play's update prompt and downloads in the background.
  /// Completes when the download has finished, the user declined, or Play
  /// reported an error.
  Future<void> startFlexibleUpdate() async {
    if (!_supported || _updateInProgress) return;
    _updateInProgress = true;
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        _readyToInstall = true;
        _offerInstall();
      }
      // userDeniedUpdate ("No thanks") / inAppUpdateFailed: keep playing.
    } catch (e) {
      debugPrint('AppUpdateService: flexible update stopped ($e)');
    } finally {
      _updateInProgress = false;
    }
  }

  /// Installs the downloaded update; Google Play restarts the app.
  Future<void> completeUpdate() async {
    if (!_supported) return;
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('AppUpdateService: complete update failed ($e)');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_readyToInstall) {
      _offerInstall();
    } else if (_updateOffered && !_updateInProgress) {
      // The download may have finished while the app was in the background.
      unawaited(checkForUpdate());
    }
  }

  /// Shows the "update downloaded" dialog when the app is in the
  /// foreground and no such dialog is already open.
  void _offerInstall() {
    if (_dialogOpen) return;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return; // shown on the next resume instead
    }
    final context = navigatorKey.currentContext;
    if (context == null) return;
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateReadyDialog(
        onRestart: completeUpdate,
        onLater: () {},
      ),
    ).whenComplete(() => _dialogOpen = false);
  }
}
