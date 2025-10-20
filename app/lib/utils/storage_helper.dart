import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _settingsKey = 'app_settings';

  // Token methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // User methods
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    
    if (userString == null) return null;
    
    try {
      final userMap = json.decode(userString) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Settings methods
  static Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is String) {
      await prefs.setString('${_settingsKey}_$key', value);
    } else if (value is int) {
      await prefs.setInt('${_settingsKey}_$key', value);
    } else if (value is bool) {
      await prefs.setBool('${_settingsKey}_$key', value);
    } else if (value is double) {
      await prefs.setDouble('${_settingsKey}_$key', value);
    }
  }

  static Future<T?> getSetting<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get('${_settingsKey}_$key') as T?;
  }

  // Theme settings
  static Future<void> saveThemeMode(String themeMode) async {
    await saveSetting('theme_mode', themeMode);
  }

  static Future<String> getThemeMode() async {
    return await getSetting<String>('theme_mode') ?? 'system';
  }

  // Notification settings
  static Future<void> saveNotificationEnabled(bool enabled) async {
    await saveSetting('notifications_enabled', enabled);
  }

  static Future<bool> getNotificationEnabled() async {
    return await getSetting<bool>('notifications_enabled') ?? true;
  }

  // Language settings
  static Future<void> saveLanguage(String language) async {
    await saveSetting('language', language);
  }

  static Future<String> getLanguage() async {
    return await getSetting<String>('language') ?? 'pt';
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Clear only auth data
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeUser();
  }
}