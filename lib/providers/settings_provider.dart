import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _soundEnabled = true;
  String _defaultDifficulty = 'Medium';
  bool _notificationsEnabled = true;
  int _notificationCount = 3;

  bool get soundEnabled => _soundEnabled;
  String get defaultDifficulty => _defaultDifficulty;
  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationCount => _notificationCount;

  Future<void> loadSettings() async {
    _soundEnabled = await _storageService.getSoundEnabled();
    _defaultDifficulty = await _storageService.getDefaultDifficulty();
    _notificationsEnabled = await _storageService.getNotificationsEnabled();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storageService.setSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> setDefaultDifficulty(String difficulty) async {
    _defaultDifficulty = difficulty;
    await _storageService.setDefaultDifficulty(difficulty);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storageService.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  void clearNotifications() {
    _notificationCount = 0;
    notifyListeners();
  }
}
