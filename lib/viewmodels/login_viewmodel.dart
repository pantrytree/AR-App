import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String? _navigateToRoute;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get navigateToRoute => _navigateToRoute;

  /// Simulate login with error for demonstration
  Future<void> login() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(Duration(seconds: 1)); // Simulate network latency

    // Simulate failure for demonstration
    bool success = false; // Change to your API call result

    if (success) {
      _isLoading = false;
      _navigateToRoute = '/home';
    } else {
      _isLoading = false;
      _errorMessage = 'Login failed. Please check your credentials and try again.';
    }
    notifyListeners();
  }

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

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
