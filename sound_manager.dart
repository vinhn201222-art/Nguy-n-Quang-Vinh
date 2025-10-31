import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _sfxVolume = 0.7;
  double _musicVolume = 0.3;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_musicVolume);
  }

  // Toggle sounds on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    if (!_soundEnabled) {
      _sfxPlayer.stop();
    }
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      playBackgroundMusic();
    } else {
      _bgmPlayer.pause();
    }
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_musicVolume);
  }

  // Play sound effects
  Future<void> playJump() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/jump.mp3'), volume: _sfxVolume);
    } catch (e) {
      debugPrint('Error playing jump sound: $e');
    }
  }

  Future<void> playScore() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/score.mp3'), volume: _sfxVolume * 0.8);
    } catch (e) {
      debugPrint('Error playing score sound: $e');
    }
  }

  Future<void> playGameOver() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/gameover.mp3'), volume: _sfxVolume);
    } catch (e) {
      debugPrint('Error playing gameover sound: $e');
    }
  }

  // ← THÊM METHOD NÀY (thiếu trong file cũ)
  Future<void> playObstacleHit() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/hit.mp3'), volume: _sfxVolume * 0.6);
    } catch (e) {
      debugPrint('Error playing hit sound: $e');
    }
  }

  Future<void> playPowerUp() async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/powerup.mp3'), volume: _sfxVolume);
    } catch (e) {
      debugPrint('Error playing powerup sound: $e');
    }
  }

  // Background music
  Future<void> playBackgroundMusic() async {
    
    if (!_musicEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'), volume: _musicVolume);
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (_musicEnabled) {
      try {
        await _bgmPlayer.resume();
      } catch (e) {
        debugPrint('Error resuming background music: $e');
      }
    }
  }

  // Cleanup
  void dispose() {
    _sfxPlayer.dispose();
    _bgmPlayer.dispose();
  }
}