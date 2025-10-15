import 'package:flutter/foundation.dart';

class SettingsViewModel extends ChangeNotifier {
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;

  // Navigation methods
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
    _navigateToRoute = '/help'; // Connect to your help page
    notifyListeners();
  }

  void navigateToProfile() {
    _navigateToRoute = '/edit_profile';
    notifyListeners();
  }

  void navigateToLogout() {
    _navigateToRoute = '/logout'; // Connect to your logout page
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }
}