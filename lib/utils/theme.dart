import 'package:flutter/foundation.dart';

// Manages application theme state (light/dark mode) using ChangeNotifier
// Provides centralized theme control with observer pattern for UI updates
class ThemeManager extends ChangeNotifier {
  // Singleton instance for global theme access
  static final ThemeManager _instance = ThemeManager._internal();
  
  // Factory constructor returns the singleton instance
  factory ThemeManager() => _instance;
  
  // Private internal constructor for singleton pattern
  ThemeManager._internal();

  bool _isDarkMode = false; // Current theme state (false = light, true = dark)

  // Returns the current theme mode
  // true = dark mode, false = light mode
  bool get isDarkMode => _isDarkMode;

  // Toggles between light and dark theme modes
  // Notifies all listeners to trigger UI rebuilds with new theme
  void toggleTheme(bool value) {
    print('ThemeManager: Toggling theme to ${value ? 'DARK' : 'LIGHT'}');
    _isDarkMode = value;
    
    // Notify all registered listeners (widgets) to rebuild with new theme
    notifyListeners();
    
    print('ThemeManager: Notified ${_isDarkMode ? 'DARK' : 'LIGHT'}');
  }
}
