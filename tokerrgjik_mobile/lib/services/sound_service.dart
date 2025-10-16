import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class SoundService {
  static final AudioPlayer _effectPlayer = AudioPlayer();
  static final AudioPlayer _musicPlayer = AudioPlayer();
  
  static bool _soundEnabled = true;
  static bool _musicEnabled = true;
  static bool _initialized = false;
  
  // Sound effects paths - using MP3 (the actual format in assets/)
  static const String _placePieceSound = 'sounds/place.mp3';
  static const String _movePieceSound = 'sounds/move.mp3';
  static const String _removePieceSound = 'sounds/remove.mp3';
  static const String _millSound = 'sounds/mill.mp3';
  static const String _winSound = 'sounds/win.mp3';
  static const String _loseSound = 'sounds/lose.mp3';
  static const String _clickSound = 'sounds/click.mp3';
  static const String _coinSound = 'sounds/coin.mp3';
  static const String _backgroundMusic = 'sounds/background.mp3';
  
  static void initialize({bool sound = true, bool music = true}) async {
    if (_initialized) return;
    
    _soundEnabled = sound;
    _musicEnabled = music;
    
    try {
      // Configure audio players for better compatibility
      await _effectPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      
      // Set volume
      await _effectPlayer.setVolume(0.7);
      await _musicPlayer.setVolume(0.3);
      
      // On Windows, audioplayers may have issues with MP3
      // Try to preload one sound to test compatibility
      if (Platform.isWindows) {
        try {
          // Test if audio works
          await _effectPlayer.setSource(AssetSource(_clickSound));
        } catch (e) {
          print('⚠️  Audio may not work on Windows with MP3 files.');
          print('   Consider converting to WAV format for better compatibility.');
          // Disable sounds on Windows if they don't work
          _soundEnabled = false;
          _musicEnabled = false;
        }
      }
      
      _initialized = true;
    } catch (e) {
      print('Sound initialization error: $e');
      // Gracefully disable sounds if initialization fails
      _soundEnabled = false;
      _musicEnabled = false;
    }
  }
  
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _effectPlayer.stop();
    }
  }
  
  static void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (enabled) {
      playBackgroundMusic();
    } else {
      _musicPlayer.stop();
    }
  }
  
  static Future<void> playSound(String sound) async {
    if (!_soundEnabled || !_initialized) return;
    
    try {
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource(sound));
    } catch (e) {
      // Silently fail if sound not found or unsupported format
      // This prevents crashes on Windows where MP3 may not be fully supported
      print('Audio playback error: $e');
    }
  }
  
  static Future<void> playBackgroundMusic() async {
    if (!_musicEnabled || !_initialized) return;
    
    try {
      await _musicPlayer.play(AssetSource(_backgroundMusic));
    } catch (e) {
      // Silently fail - background music is optional
      print('Background music error: $e');
    }
  }
  
  static void stopBackgroundMusic() {
    _musicPlayer.stop();
  }
  
  // Convenience methods
  static void playPlacePiece() => playSound(_placePieceSound);
  static void playMovePiece() => playSound(_movePieceSound);
  static void playRemovePiece() => playSound(_removePieceSound);
  static void playMill() => playSound(_millSound);
  static void playWin() => playSound(_winSound);
  static void playLose() => playSound(_loseSound);
  static void playClick() => playSound(_clickSound);
  static void playCoin() => playSound(_coinSound);
  
  static void dispose() {
    _effectPlayer.dispose();
    _musicPlayer.dispose();
  }
}
