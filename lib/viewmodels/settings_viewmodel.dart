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