// SettingsViewModel - User Preferences and Navigation
//
// PURPOSE: Manages app settings and navigation to preference pages
//
// FEATURES:
// - Theme mode management (dark/light)
// - Navigation routing for settings sections
// - Placeholder for user profile management
//
// BACKEND INTEGRATION:
// - TO DO: Sync theme preference via PUT /api/user/preferences
// - TO DO: User profile management via /api/user/profile
// - TO DO: Language and notification preferences

import 'package:flutter/foundation.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;

  // Navigation flags
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  // Getters
  bool get isDarkMode => _isDarkMode;
  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;

  // Theme method - ONLY ONE
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Navigation methods - KEEP ALL OF THESE
  void navigateToLanguage() {
    _navigateToRoute = '/language';
    notifyListeners();
  }

  void navigateToNotifications() {
    _navigateToRoute = '/notifications';
    notifyListeners();
  }

  void navigateToAbout() {
    _navigateToRoute = '/about';
    notifyListeners();
  }

  void navigateToHelp() {
    _navigateToRoute = '/help';
    notifyListeners();
  }

  void navigateToProfile() {
    _navigateToRoute = '/profile';
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }
}