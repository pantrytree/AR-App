import 'package:flutter/foundation.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Theme method - ONLY ONE VERSION
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}