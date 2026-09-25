import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/level_select/level_select_screen.dart';
import 'screens/game/game_screen.dart';
import 'screens/how_to_play/how_to_play_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/admob_service.dart';
import 'services/app_update_service.dart';
import 'services/audio/audio_service.dart';
import 'services/economy/economy_service.dart';
import 'services/haptics/haptic_service.dart';
import 'services/settings/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase and settings load in parallel; both are needed before the
  // first frame (crash reporting, sound/haptics preferences).
  final settings = createSettingsService();
  await Future.wait([
    _initFirebase(),
    settings.init().catchError((_) {}),
  ]);
  try {
    await HapticService.initialize(settings);
  } catch (_) {}
  EconomyProvider.instance.init();

  runApp(const ArrowEscapeApp());

  // Sound players load in the background (play() waits for them if needed).
  unawaited(AudioService.instance
      .initialize(settings: settings)
      .catchError((_) {}));
  unawaited(_initAds());
  // Google Play in-app update check (once per launch, after startup).
  AppUpdateService.instance.start();
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, stack) {
    debugPrint('Firebase init failed: $e');
    // Ensure Crashlytics still captures this init failure as non-fatal.
    try {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'Firebase init failed');
    } catch (_) {}
  }
}

Future<void> _initAds() async {
  try {
    await AdmobService.instance.initialize();
  } catch (_) {}
}

class ArrowEscapeApp extends StatelessWidget {
  const ArrowEscapeApp({super.key});

  static FirebaseAnalytics? _analyticsForObserver() {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _analyticsForObserver();
    return MaterialApp(
      navigatorKey: AppUpdateService.navigatorKey,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      navigatorObservers: [
        if (analytics != null)
          FirebaseAnalyticsObserver(analytics: analytics),
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/level_select': (context) => const LevelSelectScreen(),
        '/game': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return GameScreen(
            levelNumber: args?['levelNumber'] ?? 1,
            level: args?['level'],
          );
        },
        '/settings': (context) => const SettingsScreen(),
        '/how_to_play': (context) => const HowToPlayScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
