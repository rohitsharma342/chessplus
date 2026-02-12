import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _defaultDifficultyKey = 'default_difficulty';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  Future<String> getDefaultDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultDifficultyKey) ?? 'Medium';
  }

  Future<void> setDefaultDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultDifficultyKey, difficulty);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
}
