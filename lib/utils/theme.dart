// ThemeManager - Application Theme State Management
//
// PURPOSE: Manages dark/light mode theming across the entire app
//
// IMPLEMENTATION:
// - Singleton pattern ensures single source of truth for theme state
// - Uses ChangeNotifier for reactive theme updates
// - Integrated with MaterialApp themeMode for automatic theming
//
// USAGE:
// - Access via Provider.of<ThemeManager>(context)
// - Toggle with toggleTheme(true/false)
// - Check current mode with isDarkMode
//
// BACKEND INTEGRATION:
// - Future: Sync theme preference with user profile via API

import 'package:flutter/foundation.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Toggle between dark and light theme modes
  //
  // @param value: true for dark mode, false for light mode
  // @notify: Updates all listening widgets automatically
  // Theme method - ONLY ONE VERSION
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}