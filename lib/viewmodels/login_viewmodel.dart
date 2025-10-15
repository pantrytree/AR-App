import 'package:flutter/material.dart';
import 'package:roomantics/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';
  String? _navigateToRoute;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get navigateToRoute => _navigateToRoute;

  Future<void> login() async {
    // Validate inputs
    if (emailController.text.trim().isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return;
    }

    if (passwordController.text.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('LoginViewModel: Starting login...');

      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      _isLoading = false;

      if (result['success'] == true) {
        print('LoginViewModel: Login successful');
        print('User: ${result['email']}');

        // Navigate to home
        _navigateToRoute = '/home';
      } else {
        print('LoginViewModel: Login failed');
        _errorMessage = result['error'] ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again later.';
      print('LoginViewModel error: $e');
    }

    notifyListeners();
  }

  void onSignUpTapped() {
    _navigateToRoute = '/signup';
    notifyListeners();
  }

  void onBackButtonTapped() {
    _navigateToRoute = '/splash';
    notifyListeners();
  }

  void onForgotPasswordTapped() {
    _navigateToRoute = '/forgot_password';
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}