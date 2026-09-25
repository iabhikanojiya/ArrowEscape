import 'package:audioplayers/audioplayers.dart';

import '../settings/settings_service.dart';

enum GameSound {
  tap('tap.wav'),
  move('move.wav'),
  exit('exit.wav'),
  blocked('blocked.wav'),
  button('button.wav'),
  hint('hint.wav'),
  levelComplete('level_complete.wav'),
  restart('restart.wav');

  const GameSound(this.fileName);
  final String fileName;
}

class AudioService {
  AudioService._internal();

  static final AudioService instance = AudioService._internal();

  factory AudioService() => instance;

  SettingsService? _settings;
  bool _enabled = true;
  bool _initialized = false;
  final Map<GameSound, AudioPlayer?> _players = {};

  Future<void>? _initializing;

  /// Loads the sound players. Concurrent calls share one in-flight load, and
  /// all players are prepared in parallel so startup is not held up.
  Future<void> initialize({SettingsService? settings}) {
    if (settings != null) _settings = settings;
    return _initializing ??=
        _load().whenComplete(() => _initializing = null);
  }

  Future<void> _load() async {
    if (_settings != null) {
      try {
        _enabled = await _settings!.getSoundEnabled();
      } catch (_) {}
    }
    await Future.wait([
      for (final sound in GameSound.values)
        if (_players[sound] == null) _loadPlayer(sound),
    ]);
    _initialized = true;
  }

  Future<void> _loadPlayer(GameSound sound) async {
    try {
      final player = AudioPlayer(playerId: 'fx_${sound.name}')
        ..setReleaseMode(ReleaseMode.stop);
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setVolume(_volumeFor(sound));
      // Pre-load source; play() will re-set it each time for reliability
      await player.setSource(AssetSource('sounds/${sound.fileName}'));
      _players[sound] = player;
    } catch (_) {
      _players[sound] = null;
    }
  }

  bool get enabled => _enabled;

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final settings = _settings;
    if (settings != null) {
      try {
        await settings.setSoundEnabled(value);
      } catch (_) {}
    } else {
      // Fallback: persist via new instance if _settings not yet set
      try {
        final s = createSettingsService();
        await s.init();
        await s.setSoundEnabled(value);
        _settings = s;
      } catch (_) {}
    }
  }

  /// Plays [sound] respecting [_enabled].
  /// Fixed to work reliably after first interaction:
  /// - correctly sequences stop -> play with AssetSource
  /// - falls back to transient player if pooled player fails
  /// - reinitializes lazily if initialize not yet completed
  Future<void> play(GameSound sound) async {
    if (!_enabled) return;
    if (!_initialized) {
      try {
        await initialize();
      } catch (_) {}
    }
    // Refresh enabled from settings to respect changes made via other instances
    if (_settings != null) {
      try {
        _enabled = await _settings!.getSoundEnabled();
        if (!_enabled) return;
      } catch (_) {}
    }

    final double volume = _volumeFor(sound);
    final player = _players[sound];

    if (player != null) {
      try {
        // Ensure any previous playback is stopped before starting new one
        try {
          await player.stop();
        } catch (_) {}
        // lowLatency + fresh AssetSource play is most reliable after stop
        await player.setVolume(volume);
        await player.play(
          AssetSource('sounds/${sound.fileName}'),
          volume: volume,
          mode: PlayerMode.lowLatency,
        );
        return;
      } catch (_) {
        // fall through to transient fallback
      }
    }

    // Fallback: one-shot transient player (guaranteed to work even if pool is broken)
    try {
      final tmp = AudioPlayer();
      await tmp.setVolume(volume);
      await tmp.play(
        AssetSource('sounds/${sound.fileName}'),
        volume: volume,
        mode: PlayerMode.lowLatency,
      );
      // Auto-dispose after playback to avoid leaks
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          await tmp.stop();
          await tmp.dispose();
        } catch (_) {}
      });
    } catch (_) {}
  }

  double _volumeFor(GameSound sound) {
    switch (sound) {
      case GameSound.blocked:
        return 0.5;
      case GameSound.levelComplete:
        return 0.6;
      default:
        return 0.45;
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      try {
        await player?.dispose();
      } catch (_) {}
    }
    _players.clear();
    _initialized = false;
  }
}
