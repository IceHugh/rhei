import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:audioplayers/audioplayers.dart'; // Keep commented until assets are real, or use if we find a URL mechanism.

enum TimerMode { focus, shortBreak, longBreak }

class TimerService with ChangeNotifier {
  static const platform = MethodChannel('com.example.flow/timer');

  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  TimerMode _currentMode = TimerMode.focus;

  // Settings
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  bool _loopMode = false; // "Auto-run" / "Loop"
  int _cycleCount = 0; // Tracks consecutive focus sessions
  
  // bool _autoStartBreaks = false; // Deprecated by Loop Mode
  // bool _autoStartPomodoros = false; // Deprecated by Loop Mode
  String _themeMode = 'system'; // 'system', 'light', 'dark'
  bool _tickSound = false;
  String _alarmSound = 'bell';
  bool _enableNotifications = true;
  bool _alwaysOnTop = false;

  // Notifications
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Getters
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  TimerMode get currentMode => _currentMode;
  int get totalSeconds => _getTotalSecondsForMode(_currentMode);
  double get progress => _remainingSeconds / totalSeconds;
  
  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  bool get loopMode => _loopMode;
  // bool get autoStartBreaks => _autoStartBreaks;
  // bool get autoStartPomodoros => _autoStartPomodoros;
  String get themeMode => _themeMode;
  bool get tickSound => _tickSound;
  String get alarmSound => _alarmSound;
  bool get enableNotifications => _enableNotifications;
  bool get alwaysOnTop => _alwaysOnTop;

  TimerService() {
    _loadSettings();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _focusMinutes = prefs.getInt('focusMinutes') ?? 25;
    _shortBreakMinutes = prefs.getInt('shortBreakMinutes') ?? 5;
    _longBreakMinutes = prefs.getInt('longBreakMinutes') ?? 15;
    _loopMode = prefs.getBool('loopMode') ?? false;
    // _autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
    // _autoStartPomodoros = prefs.getBool('autoStartPomodoros') ?? false;
    _themeMode = prefs.getString('themeMode') ?? 'system';
    _tickSound = prefs.getBool('tickSound') ?? false;
    _alarmSound = prefs.getString('alarmSound') ?? 'bell';
    _enableNotifications = prefs.getBool('enableNotifications') ?? true;
    _alwaysOnTop = prefs.getBool('alwaysOnTop') ?? false;
    
    // Apply window settings
    if (_alwaysOnTop) {
      _applyAlwaysOnTop(true);
    }

    // Initialize timer with loaded focus time if strictly starting fresh
    if (!_isRunning && _currentMode == TimerMode.focus && _remainingSeconds == 25 * 60) {
       _remainingSeconds = _focusMinutes * 60;
    }
    notifyListeners();
  }

  Future<void> updateSettings({
    int? focus,
    int? shortBreak,
    int? longBreak,
    // bool? autoStartBreaks, // Deprecated
    // bool? autoStartPomos, // Deprecated
    bool? loopMode,
    String? themeMode,
    bool? tickSound,
    String? alarmSound,
    bool? enableNotifications,
    bool? alwaysOnTop,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (focus != null) {
      _focusMinutes = focus;
      prefs.setInt('focusMinutes', focus);
      if (_currentMode == TimerMode.focus && !_isRunning) {
        _remainingSeconds = focus * 60;
      }
    }
    if (shortBreak != null) {
      _shortBreakMinutes = shortBreak;
      prefs.setInt('shortBreakMinutes', shortBreak);
      if (_currentMode == TimerMode.shortBreak && !_isRunning) {
        _remainingSeconds = shortBreak * 60;
      }
    }
    if (longBreak != null) {
      _longBreakMinutes = longBreak;
      prefs.setInt('longBreakMinutes', longBreak);
      if (_currentMode == TimerMode.longBreak && !_isRunning) {
        _remainingSeconds = longBreak * 60;
      }
    }
    // if (autoStartBreaks != null) { 
    //    // Legacy support if needed
    // }
    // New Loop param
    if (loopMode != null) {
      _loopMode = loopMode;
      prefs.setBool('loopMode', loopMode);
    }
    if (themeMode != null) {
      _themeMode = themeMode;
      prefs.setString('themeMode', themeMode);
    }
    if (tickSound != null) {
      _tickSound = tickSound;
      prefs.setBool('tickSound', tickSound);
    }
    if (alarmSound != null) {
      _alarmSound = alarmSound;
      prefs.setString('alarmSound', alarmSound);
    }
    if (enableNotifications != null) {
      _enableNotifications = enableNotifications;
      prefs.setBool('enableNotifications', enableNotifications);
    }
    if (alwaysOnTop != null) {
      _alwaysOnTop = alwaysOnTop;
      prefs.setBool('alwaysOnTop', alwaysOnTop);
      _applyAlwaysOnTop(alwaysOnTop);
    }
    notifyListeners();
  }

  void _applyAlwaysOnTop(bool alwaysOnTop) async {
    try {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting always on top: $e');
      }
    }
  }

  int _getTotalSecondsForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return _focusMinutes * 60;
      case TimerMode.shortBreak:
        return _shortBreakMinutes * 60;
      case TimerMode.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  void setMode(TimerMode mode) {
    _stopTimer(resetUI: false);
    _currentMode = mode;
    _remainingSeconds = _getTotalSecondsForMode(mode);
    _updateBadge();
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      _stopTimer(resetUI: false);
    } else {
      _startTimer();
    }
  }

  void resetTimer() {
    _stopTimer(resetUI: true);
    _remainingSeconds = _getTotalSecondsForMode(_currentMode);
    _updateBadge();
    notifyListeners();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateBadge();
        
        // Tick sound
        if (_tickSound) {
          // Use system click sound as a simple tick
          SystemSound.play(SystemSoundType.click);
        }
        
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    notifyListeners();
  }

  void _stopTimer({required bool resetUI}) {
    _timer?.cancel();
    _isRunning = false;
    if (resetUI) {
      _clearBadge();
    }
    notifyListeners();
  }

  Future<void> _onTimerComplete() async {
    _stopTimer(resetUI: true);
    HapticFeedback.heavyImpact();
    
    // Show Notification
    if (_enableNotifications) {
      String title = _currentMode == TimerMode.focus ? "Focus Session Complete!" : "Break Over!";
      String body = _currentMode == TimerMode.focus ? "Time to take a break." : "Ready to focus again?";
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('flow_timer_channel', 'Timer Notifications',
              channelDescription: 'Notifications for timer completion',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
          
      await _notificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
    }

    // Auto-switch logic
    // Play Completion Sound
    _playCompletionSound();

    // Loop / Cycle Logic
    if (_loopMode) {
      if (_currentMode == TimerMode.focus) {
        _cycleCount++;
        if (_cycleCount % 4 == 0) {
          // 4th Focus done -> Long Break
          setMode(TimerMode.longBreak);
        } else {
          // Standard Focus done -> Short Break
          setMode(TimerMode.shortBreak);
        }
        _startTimer();
      } else {
        // Break done -> Back to Focus
        setMode(TimerMode.focus);
        _startTimer();
      }
    } else {
      // If not looping, we might still want to advance the mode but PAUSE?
      // For now, standard behavior is just stop.
      // But maybe we reset the *next* mode ready to go?
      // Let's keep it simple: Stop.
    }
    
    notifyListeners();
  }

  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void previewSound(String soundName) {
    if (soundName == 'bell') {
       SystemSound.play(SystemSoundType.click); // Placeholder for Bell
    } else if (soundName == 'digital') {
       // Placeholder
       SystemSound.play(SystemSoundType.alert);
    }
    
    // Always heavy impact
    HapticFeedback.heavyImpact();
  }

  void _playCompletionSound() {
    previewSound(_alarmSound);
  }

  void _updateBadge() {
    try {
      String prefix = _currentMode == TimerMode.focus ? "🍅 " : "☕️ ";
      platform.invokeMethod('updateTimer', {'time': "$prefix$formattedTime"});
    } catch (e) {
      // Ignore
    }
  }

  void _clearBadge() {
    try {
      platform.invokeMethod('clearTimer');
    } catch (e) {
      // Ignore
    }
  }
}
