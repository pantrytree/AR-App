import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static const String _themePreferenceKey = 'theme_preference';

  bool _isDarkMode = false;
  bool _isInitialized = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing theme: $e');
      _isInitialized = true;
    }
  }

  Future<void> toggleTheme(bool value) async {
    if (_isDarkMode == value) return;

    _isDarkMode = value;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }

    notifyListeners();
  }
}