import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  final NotificationService _notificationService = NotificationService();

  SettingsViewModel(this._prefs) {
    _loadSettings();
  }

  bool _savingReminderEnabled = false;
  int _savingReminderInterval = 6; // Hours
  bool _eventCountdownEnabled = false;
  int _eventCountdownDays = 1;
  TimeOfDay _eventCountdownTime = const TimeOfDay(hour: 9, minute: 0);
  bool _eventReminderBeforeEnabled = false;
  int _eventReminderBeforeHours = 1;

  bool get savingReminderEnabled => _savingReminderEnabled;
  int get savingReminderInterval => _savingReminderInterval;
  bool get eventCountdownEnabled => _eventCountdownEnabled;
  int get eventCountdownDays => _eventCountdownDays;
  TimeOfDay get eventCountdownTime => _eventCountdownTime;
  bool get eventReminderBeforeEnabled => _eventReminderBeforeEnabled;
  int get eventReminderBeforeHours => _eventReminderBeforeHours;

  void _loadSettings() {
    _savingReminderEnabled = _prefs.getBool('savingReminderEnabled') ?? false;
    _savingReminderInterval = _prefs.getInt('savingReminderInterval') ?? 6;
    _eventCountdownEnabled = _prefs.getBool('eventCountdownEnabled') ?? false;
    _eventCountdownDays = _prefs.getInt('eventCountdownDays') ?? 1;
    
    int hour = _prefs.getInt('eventCountdownHour') ?? 9;
    int minute = _prefs.getInt('eventCountdownMinute') ?? 0;
    _eventCountdownTime = TimeOfDay(hour: hour, minute: minute);
    
    _eventReminderBeforeEnabled = _prefs.getBool('eventReminderBeforeEnabled') ?? false;
    _eventReminderBeforeHours = _prefs.getInt('eventReminderBeforeHours') ?? 1;
    
    notifyListeners();
  }

  Future<void> setSavingReminderEnabled(bool value) async {
    _savingReminderEnabled = value;
    await _prefs.setBool('savingReminderEnabled', value);
    if (value) {
      await _notificationService.requestPermissions();
      _scheduleSavingReminders();
    } else {
      await _notificationService.cancelNotification(100); // ID 100 for saving reminder
    }
    notifyListeners();
  }

  Future<void> setSavingReminderInterval(int value) async {
    _savingReminderInterval = value;
    await _prefs.setInt('savingReminderInterval', value);
    if (_savingReminderEnabled) {
      _scheduleSavingReminders();
    }
    notifyListeners();
  }

  Future<void> setEventCountdownEnabled(bool value) async {
    _eventCountdownEnabled = value;
    await _prefs.setBool('eventCountdownEnabled', value);
    if (value) {
      await _notificationService.requestPermissions();
    } else {
      // Cancellation of all event IDs would be needed if we tracked them
    }
    notifyListeners();
  }

  Future<void> setEventCountdownDays(int value) async {
    _eventCountdownDays = value;
    await _prefs.setInt('eventCountdownDays', value);
    notifyListeners();
  }

  Future<void> setEventCountdownTime(TimeOfDay value) async {
    _eventCountdownTime = value;
    await _prefs.setInt('eventCountdownHour', value.hour);
    await _prefs.setInt('eventCountdownMinute', value.minute);
    notifyListeners();
  }

  Future<void> setEventReminderBeforeEnabled(bool value) async {
    _eventReminderBeforeEnabled = value;
    await _prefs.setBool('eventReminderBeforeEnabled', value);
    if (value) await _notificationService.requestPermissions();
    notifyListeners();
  }

  Future<void> setEventReminderBeforeHours(int value) async {
    _eventReminderBeforeHours = value;
    await _prefs.setInt('eventReminderBeforeHours', value);
    notifyListeners();
  }

  void _scheduleSavingReminders() {
    _notificationService.scheduleSavingReminder(
      id: 100,
      intervalHours: _savingReminderInterval,
    );
  }
}
