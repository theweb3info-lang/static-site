import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/pomodoro_session.dart';
import '../services/notification_service.dart';
import '../services/platform_service.dart';
import '../services/tray_service.dart';
import 'settings_provider.dart';
import 'statistics_provider.dart';

enum TimerState {
  idle,
  running,
  paused,
}

class TimerProvider extends ChangeNotifier {
  final SettingsProvider settings;
  final StatisticsProvider statistics;
  
  Timer? _timer;
  TimerState _state = TimerState.idle;
  SessionType _currentSessionType = SessionType.focus;
  int _remainingSeconds = 0;
  int _completedPomodoros = 0;
  String? _currentTaskId;
  PomodoroSession? _currentSession;

  TimerProvider({
    required this.settings,
    required this.statistics,
  }) {
    _remainingSeconds = settings.focusDuration * 60;
  }

  // Getters
  TimerState get state => _state;
  SessionType get currentSessionType => _currentSessionType;
  int get remainingSeconds => _remainingSeconds;
  int get completedPomodoros => _completedPomodoros;
  String? get currentTaskId => _currentTaskId;
  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isIdle => _state == TimerState.idle;

  int get totalSeconds {
    switch (_currentSessionType) {
      case SessionType.focus:
        return settings.focusDuration * 60;
      case SessionType.shortBreak:
        return settings.shortBreakDuration * 60;
      case SessionType.longBreak:
        return settings.longBreakDuration * 60;
    }
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionTypeLabel {
    switch (_currentSessionType) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  void setCurrentTask(String? taskId) {
    _currentTaskId = taskId;
    notifyListeners();
  }

  void start() {
    if (_state == TimerState.running) return;

    _state = TimerState.running;
    
    if (_currentSession == null) {
      _currentSession = PomodoroSession(
        id: const Uuid().v4(),
        type: _currentSessionType,
        durationMinutes: totalSeconds ~/ 60,
        startTime: DateTime.now(),
        taskId: _currentTaskId,
      );
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _updateTray();
    notifyListeners();
  }

  void pause() {
    if (_state != TimerState.running) return;

    _timer?.cancel();
    _state = TimerState.paused;
    _updateTray();
    notifyListeners();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    start();
  }

  void stop() {
    _timer?.cancel();
    _state = TimerState.idle;
    _currentSession = null;
    _resetToCurrentSession();
    _updateTray();
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _completeSession(skipped: true);
  }

  void reset() {
    _timer?.cancel();
    _state = TimerState.idle;
    _currentSession = null;
    _resetToCurrentSession();
    _updateTray();
    notifyListeners();
  }

  void _tick() {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      _updateTray();
      notifyListeners();
    } else {
      _completeSession();
    }
  }

  void _completeSession({bool skipped = false}) {
    _timer?.cancel();
    
    if (!skipped && _currentSessionType == SessionType.focus) {
      _completedPomodoros++;
      
      // Record statistics
      statistics.recordCompletedPomodoro(
        settings.focusDuration,
        _currentTaskId,
      );
      
      // Send notification
      NotificationService.instance.showNotification(
        title: 'Focus Complete! 🎉',
        body: 'Time for a break. You\'ve completed $_completedPomodoros pomodoro${_completedPomodoros > 1 ? 's' : ''} today!',
      );

      // Lock screen if enabled
      if (settings.lockScreenOnBreak) {
        PlatformService.instance.lockScreen();
      }
    } else if (!skipped) {
      NotificationService.instance.showNotification(
        title: 'Break Over! 💪',
        body: 'Ready to get back to work?',
      );
    }

    // Determine next session type
    _moveToNextSession();
    
    // Auto-start if enabled
    if (_currentSessionType == SessionType.focus && settings.autoStartPomodoros) {
      start();
    } else if (_currentSessionType != SessionType.focus && settings.autoStartBreaks) {
      start();
    }
    
    _updateTray();
    notifyListeners();
  }

  void _moveToNextSession() {
    _state = TimerState.idle;
    _currentSession = null;

    if (_currentSessionType == SessionType.focus) {
      // After focus, determine break type
      if (_completedPomodoros > 0 && 
          _completedPomodoros % settings.pomodorosUntilLongBreak == 0) {
        _currentSessionType = SessionType.longBreak;
      } else {
        _currentSessionType = SessionType.shortBreak;
      }
    } else {
      // After any break, go back to focus
      _currentSessionType = SessionType.focus;
    }
    
    _resetToCurrentSession();
  }

  void _resetToCurrentSession() {
    switch (_currentSessionType) {
      case SessionType.focus:
        _remainingSeconds = settings.focusDuration * 60;
        break;
      case SessionType.shortBreak:
        _remainingSeconds = settings.shortBreakDuration * 60;
        break;
      case SessionType.longBreak:
        _remainingSeconds = settings.longBreakDuration * 60;
        break;
    }
  }

  void setSessionType(SessionType type) {
    if (_state == TimerState.running) return;
    
    _currentSessionType = type;
    _currentSession = null;
    _resetToCurrentSession();
    _updateTray();
    notifyListeners();
  }

  void _updateTray() {
    TrayService.instance.updateTrayTitle(
      formattedTime,
      _state == TimerState.running,
      _currentSessionType,
    );
  }

  void addMinute() {
    _remainingSeconds += 60;
    notifyListeners();
  }

  void subtractMinute() {
    if (_remainingSeconds > 60) {
      _remainingSeconds -= 60;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
