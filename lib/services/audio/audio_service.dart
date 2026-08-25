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
  final Map<GameSound, AudioPlayer?> _players = {};

  Future<void> initialize({SettingsService? settings}) async {
    _settings = settings ?? _settings;
    if (_settings != null) {
      try {
        _enabled = await _settings!.getSoundEnabled();
      } catch (_) {}
    }
    for (final sound in GameSound.values) {
      if (_players.containsKey(sound)) continue;
      try {
        final player = AudioPlayer(playerId: 'fx_${sound.name}')
          ..setReleaseMode(ReleaseMode.stop);
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setVolume(_volumeFor(sound));
        await player.setSource(AssetSource('sounds/${sound.fileName}'));
        _players[sound] = player;
      } catch (_) {
        _players[sound] = null;
      }
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
    }
  }

  void play(GameSound sound) {
    if (!_enabled) return;
    final player = _players[sound];
    if (player == null) return;
    player
      ..stop()
      ..resume().catchError((_) => null);
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
  }
}
