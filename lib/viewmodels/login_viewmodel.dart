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

  // Instantly navigates to home after login button is pressed
  Future<void> login() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(Duration(seconds: 1)); // Optional: show spinner

    _isLoading = false;
    _navigateToRoute = '/home';
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
}
