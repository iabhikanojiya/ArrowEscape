import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'economy/economy_service.dart';

/// Google Play Games Services v2 (Android only), via `games_services`.
///
/// All Play Games calls in the app go through here. Every method is
/// best-effort: failures, timeouts and missing Play Games are swallowed so
/// the game keeps working when the player isn't signed in.
class PlayGamesService {
  PlayGamesService._();
  static final PlayGamesService instance = PlayGamesService._();

  /// "Coins Earned" leaderboard ID from Play Console
  /// (Play Games Services > Leaderboards).
  static const String coinsEarnedLeaderboardId = 'CgkIr4bigc8GEAIAQ';

  static const String _lastSubmittedKey = 'play_games_last_submitted_coins';

  // The plugin never answers if no Activity is attached, so every call is
  // bounded to avoid hanging futures.
  static const Duration _authTimeout = Duration(seconds: 15);
  static const Duration _callTimeout = Duration(seconds: 10);
  // The interactive sign-in sheet waits on the player.
  static const Duration _interactiveTimeout = Duration(minutes: 2);

  bool _isSignedIn = false;
  Future<bool>? _initFuture;
  // Serialises submissions so rapid coin changes can't race each other.
  Future<void> _submitQueue = Future<void>.value();

  bool get isSignedIn => _isSignedIn;

  bool get _isSupported => !kIsWeb && Platform.isAndroid;

  /// Picks up the silent sign-in Play Games v2 performs on launch and starts
  /// following the coin balance. Never shows UI. Safe to call more than once.
  Future<bool> initialize() => _initFuture ??= _initialize();

  Future<bool> _initialize() async {
    if (!_isSupported) return false;
    // Every coin change in the game goes through the economy's notifier, so
    // this catches all earning flows without touching coin logic.
    final coins = EconomyProvider.instance.coinsListenable;
    coins.addListener(() => submitCoinsEarned(coins.value));
    try {
      _isSignedIn = await GameAuth.isSignedIn.timeout(_authTimeout);
    } catch (e) {
      _log('auth check failed: $e');
      _isSignedIn = false;
    }
    if (_isSignedIn) unawaited(_submitCurrentCoins());
    return _isSignedIn;
  }

  /// Interactive sign-in. Call only from a player action (e.g. a button).
  Future<bool> signIn() async {
    if (!_isSupported) return false;
    if (_isSignedIn) return true;
    try {
      await GameAuth.signIn().timeout(_interactiveTimeout);
      _isSignedIn = true;
    } catch (e) {
      _log('sign-in failed: $e');
      _isSignedIn = false;
    }
    if (_isSignedIn) unawaited(_submitCurrentCoins());
    return _isSignedIn;
  }

  /// Submits the player's coin total to the "Coins Earned" leaderboard if it
  /// is higher than the last total submitted from this device.
  Future<void> submitCoinsEarned(int coins) =>
      _submitQueue = _submitQueue.then((_) => _submitCoins(coins));

  Future<void> _submitCoins(int coins) async {
    if (!_isSupported || !_isSignedIn || coins <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSubmitted = prefs.getInt(_lastSubmittedKey) ?? 0;
      if (coins <= lastSubmitted) return;
      await Leaderboards.submitScore(
        score: Score(
          androidLeaderboardID: coinsEarnedLeaderboardId,
          value: coins,
        ),
      ).timeout(_callTimeout);
      await prefs.setInt(_lastSubmittedKey, coins);
    } catch (e) {
      _log('score submit failed: $e');
    }
  }

  /// Opens the Play Games leaderboard UI, signing in first if needed.
  /// Returns false if Play Games is unavailable or the player declined.
  Future<bool> showLeaderboards() async {
    if (!_isSupported) return false;
    if (!await signIn()) return false;
    try {
      await Leaderboards.showLeaderboards(
        androidLeaderboardID: coinsEarnedLeaderboardId,
      ).timeout(_callTimeout);
      return true;
    } catch (e) {
      _log('show leaderboards failed: $e');
      return false;
    }
  }

  /// Catches the leaderboard up with coins earned while signed out
  /// (or before Play Games was added).
  Future<void> _submitCurrentCoins() async {
    try {
      await submitCoinsEarned(await EconomyProvider.instance.getCoins());
    } catch (e) {
      _log('coin balance sync failed: $e');
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[PlayGames] $message');
  }
}
