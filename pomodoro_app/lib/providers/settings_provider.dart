import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Timer durations (in minutes)
  int _focusDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _pomodorosUntilLongBreak = 4;
  
  // Features
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _lockScreenOnBreak = true;
  bool _showInMenuBar = true;
  
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  
  // Daily goal
  int _dailyPomodoroGoal = 8;

  // Getters
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get pomodorosUntilLongBreak => _pomodorosUntilLongBreak;
  bool get autoStartBreaks => _autoStartBreaks;
  bool get autoStartPomodoros => _autoStartPomodoros;
  bool get soundEnabled => _soundEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get lockScreenOnBreak => _lockScreenOnBreak;
  bool get showInMenuBar => _showInMenuBar;
  ThemeMode get themeMode => _themeMode;
  int get dailyPomodoroGoal => _dailyPomodoroGoal;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _focusDuration = prefs.getInt('focusDuration') ?? 25;
    _shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5;
    _longBreakDuration = prefs.getInt('longBreakDuration') ?? 15;
    _pomodorosUntilLongBreak = prefs.getInt('pomodorosUntilLongBreak') ?? 4;
    _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
    _autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _lockScreenOnBreak = prefs.getBool('lockScreenOnBreak') ?? true;
    _showInMenuBar = prefs.getBool('showInMenuBar') ?? true;
    _dailyPomodoroGoal = prefs.getInt('dailyPomodoroGoal') ?? 8;
    
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('focusDuration', _focusDuration);
    await prefs.setInt('shortBreakDuration', _shortBreakDuration);
    await prefs.setInt('longBreakDuration', _longBreakDuration);
    await prefs.setInt('pomodorosUntilLongBreak', _pomodorosUntilLongBreak);
    await prefs.setBool('autoStartBreaks', _autoStartBreaks);
    await prefs.setBool('autoStartPomodoros', _autoStartPomodoros);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('lockScreenOnBreak', _lockScreenOnBreak);
    await prefs.setBool('showInMenuBar', _showInMenuBar);
    await prefs.setInt('dailyPomodoroGoal', _dailyPomodoroGoal);
    await prefs.setInt('themeMode', _themeMode.index);
  }

  void setFocusDuration(int minutes) {
    _focusDuration = minutes.clamp(1, 120);
    _saveSettings();
    notifyListeners();
  }

  void setShortBreakDuration(int minutes) {
    _shortBreakDuration = minutes.clamp(1, 60);
    _saveSettings();
    notifyListeners();
  }

  void setLongBreakDuration(int minutes) {
    _longBreakDuration = minutes.clamp(1, 60);
    _saveSettings();
    notifyListeners();
  }

  void setPomodorosUntilLongBreak(int count) {
    _pomodorosUntilLongBreak = count.clamp(1, 10);
    _saveSettings();
    notifyListeners();
  }

  void setAutoStartBreaks(bool value) {
    _autoStartBreaks = value;
    _saveSettings();
    notifyListeners();
  }

  void setAutoStartPomodoros(bool value) {
    _autoStartPomodoros = value;
    _saveSettings();
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  void setLockScreenOnBreak(bool value) {
    _lockScreenOnBreak = value;
    _saveSettings();
    notifyListeners();
  }

  void setShowInMenuBar(bool value) {
    _showInMenuBar = value;
    _saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  void setDailyPomodoroGoal(int goal) {
    _dailyPomodoroGoal = goal.clamp(1, 20);
    _saveSettings();
    notifyListeners();
  }
}
