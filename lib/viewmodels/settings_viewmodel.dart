import 'package:flutter/material.dart';

class SettingsViewModel with ChangeNotifier {
  String? _navigateToRoute;

  String? get navigateToRoute => _navigateToRoute;

  void clearNavigation() {
    _navigateToRoute = null;
  }

  // Existing methods
  void navigateToProfile() {
    _navigateToRoute = '/profile';
    notifyListeners();
  }

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

  void navigateToLogout() {
    _navigateToRoute = '/logout';
    notifyListeners();
  }

  // New methods for the added settings options
  void navigateToChangePassword() {
    _navigateToRoute = '/change-password';
    notifyListeners();
  }

  void navigateToTwoFactorAuth() {
    _navigateToRoute = '/two-factor-auth';
    notifyListeners();
  }

  void navigateToActiveSessions() {
    _navigateToRoute = '/active-sessions';
    notifyListeners();
  }

  void navigateToPrivacyPolicy() {
    _navigateToRoute = '/privacy-policy';
    notifyListeners();
  }

  void navigateToTermsOfService() {
    _navigateToRoute = '/terms-of-service';
    notifyListeners();
  }

  // Optional: Add delete account method if needed
  void deleteAccount() {
    // Implement delete account logic here
    // This would typically show a confirmation dialog first
    // then call an API to delete the account
    _navigateToRoute = '/delete-account';
    notifyListeners();
  }
}