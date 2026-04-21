import 'package:flame_audio/flame_audio.dart';
import 'package:route_rush/data/game_state.dart';

class AudioManager {
  final GameState _gameState;

  AudioManager(this._gameState);

  bool get _sfxEnabled => _gameState.sfxEnabled;

  Future<void> preload() async {
    await FlameAudio.audioCache.loadAll([
      'ui_tap.wav',
      'ignition.wav',
      'tire_screech.wav',
      'pothole_crunch.wav',
      'nails_pop.wav',
      'barricade_crash.wav',
      'deadline_warning.wav',
      'receipt_print.wav',
      'game_over.wav',
    ]);
  }

  void playUiTap() {
    if (!_sfxEnabled) return;
    FlameAudio.play('ui_tap.wav', volume: 0.5);
  }

  void playIgnition() {
    if (!_sfxEnabled) return;
    FlameAudio.play('ignition.wav', volume: 0.7);
  }

  void playTireScreech() {
    if (!_sfxEnabled) return;
    FlameAudio.play('tire_screech.wav', volume: 0.4);
  }

  void playPotholeCrunch() {
    if (!_sfxEnabled) return;
    FlameAudio.play('pothole_crunch.wav', volume: 0.8);
  }

  void playNailsPop() {
    if (!_sfxEnabled) return;
    FlameAudio.play('nails_pop.wav', volume: 0.5);
  }

  void playBarricadeCrash() {
    if (!_sfxEnabled) return;
    FlameAudio.play('barricade_crash.wav', volume: 0.9);
  }

  void playDeadlineWarning() {
    if (!_sfxEnabled) return;
    FlameAudio.play('deadline_warning.wav', volume: 0.6);
  }

  void playReceiptPrint() {
    if (!_sfxEnabled) return;
    FlameAudio.play('receipt_print.wav', volume: 0.5);
  }

  void playGameOver() {
    if (!_sfxEnabled) return;
    FlameAudio.play('game_over.wav', volume: 0.8);
  }

  void dispose() {
    FlameAudio.bgm.stop();
  }
}
