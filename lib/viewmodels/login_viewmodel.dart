import 'package:flutter/material.dart';
import 'package:Roomantics/services/auth_service.dart';
import '../services/session_service.dart';

// ViewModel for managing login page state and authentication logic
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

  // Performs user login with email and password validation
  // Creates session on successful authentication
  Future<void> login() async {
    // Validate email input
    if (emailController.text.trim().isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return;
    }

    // Validate password input
    if (passwordController.text.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return;
    }

    // Start loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('LoginViewModel: Starting login...');

      // Attempt authentication
      final user = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      _isLoading = false;

      if (user != null) {
        // Create session for successful login
        final sessionService = SessionService();
        final sessionId = await sessionService.generateSessionId();

        await sessionService.createOrUpdateSession(
          sessionId: sessionId,
        );

        // Navigate to home on success
        _navigateToRoute = '/home';
        print('LoginViewModel: Login successful');
        print('Welcome, ${user.displayName}');
      } else {
        // Handle authentication failure
        _errorMessage = 'Invalid email or password. Please try again.';
        print('LoginViewModel: Login failed');
      }
    } catch (e) {
      // Handle unexpected errors
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again later.';
      print('LoginViewModel error: $e');
    }

    notifyListeners();
  }

  // Navigates to signup page
  void onSignUpTapped() {
    _navigateToRoute = '/signup';
    notifyListeners();
  }

  // Navigates back to splash screen
  void onBackButtonTapped() {
    _navigateToRoute = '/splash';
    notifyListeners();
  }

  // Navigates to forgot password flow
  void onForgotPasswordTapped() {
    _navigateToRoute = '/forgot-password';
    notifyListeners();
  }

  // Clears navigation state after routing
  void clearNavigation() {
    _navigateToRoute = null;
    notifyListeners();
  }

  // Validates email format and presence
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

  // Validates password presence and minimum length
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Clears error messages
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
