// TODO: All API calls name 'fakeApiLogin' to be replaced by real API calls

import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  String _errorMessage = '';
  String? _navigateToRoute;

  // Text controllers for input fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Public getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get navigateToRoute => _navigateToRoute;

  /// Main login method called by the UI
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Simple input validation
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter email and password';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // ===== Placeholder for real API/database call =====
      // Replace this with your API method
      final bool success = await fakeApiLogin(email, password);
      // ================================================

      if (success) {
        _navigateToRoute = '/home'; // Navigate on success
      } else {
        _errorMessage = 'Invalid email or password';
      }
    } catch (e) {
      _errorMessage = 'Login error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Navigation handler methods
  void onSignUpTapped() {
    _navigateToRoute = '/signup';
    notifyListeners();
  }

  void onBackButtonTapped() {
    _navigateToRoute = '/';
    notifyListeners();
  }

  void onForgotPasswordTapped() {
    _navigateToRoute = '/forgot-password';
    notifyListeners();
  }


  void clearNavigation() {
    _navigateToRoute = null;
    notifyListeners();
  }

  /// --- Placeholder function simulating an API call ---
  /// In production, replace with real HTTP/database call
  Future<bool> fakeApiLogin(String email, String password) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network latency

    // DEMO: Only accept a sample hardcoded user
    if (email == 'test@example.com' && password == 'password123') {
      return true; // Simulate success
    }
    return false; // Simulate failure
  }
}
 