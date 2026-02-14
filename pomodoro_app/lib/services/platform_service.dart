import 'package:flutter/services.dart';

class PlatformService {
  static final PlatformService instance = PlatformService._init();
  static const MethodChannel _channel = MethodChannel('com.pomodoro.app/platform');

  PlatformService._init();

  Future<void> initialize() async {
    // Any platform-specific initialization
  }

  /// Lock the screen using macOS native API
  Future<bool> lockScreen() async {
    try {
      final result = await _channel.invokeMethod<bool>('lockScreen');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to lock screen: ${e.message}');
      return false;
    }
  }

  /// Start the screensaver (alternative to lock)
  Future<bool> startScreensaver() async {
    try {
      final result = await _channel.invokeMethod<bool>('startScreensaver');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to start screensaver: ${e.message}');
      return false;
    }
  }

  /// Put display to sleep
  Future<bool> sleepDisplay() async {
    try {
      final result = await _channel.invokeMethod<bool>('sleepDisplay');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to sleep display: ${e.message}');
      return false;
    }
  }

  /// Play a system sound
  Future<void> playSystemSound(String soundName) async {
    try {
      await _channel.invokeMethod('playSystemSound', {'name': soundName});
    } on PlatformException catch (e) {
      print('Failed to play sound: ${e.message}');
    }
  }

  /// Check if running in menu bar mode
  Future<bool> isMenuBarMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('isMenuBarMode');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
