import 'package:flutter/material.dart';
import 'package:Roomantics/services/auth_service.dart';

// ViewModel for managing sign-up page state and registration logic
class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService(); 
  final formKey = GlobalKey<FormState>(); 

  // User registration data
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  // UI state management
  bool loading = false;          
  String? errorMessage;          
  String? navigateToRoute;       

  // Setters for form data with automatic UI updates
  void setName(String val) {
    name = val;
    notifyListeners();
  }

  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  void setPassword(String val) {
    password = val;
    notifyListeners();
  }

  void setConfirmPassword(String val) {
    confirmPassword = val;
    notifyListeners();
  }

  // Performs user registration with current form data
  // Navigates to home on success, shows error on failure
  Future<void> signUp() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    // Attempt user registration
    final success = await _authService.signup(
      email: email,
      password: password,
      displayName: name,
    );

    if (success) {
      navigateToRoute = '/home'; 
    } else {
      errorMessage = 'Sign up failed. Please try again.'; 
    }

    loading = false;
    notifyListeners();
  }

  // Validates name field - ensures non-empty value
  String? nameValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Name required' : null;

  // Validates email format and presence
  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  // Validates password strength with multiple criteria
  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password required';

    // Minimum length requirement
    if (v.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Uppercase letter requirement
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Lowercase letter requirement
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Number requirement
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Password must contain at least one number';
    }

    // Special character requirement
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Validates password confirmation matches original password
  String? confirmPasswordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != password) return 'Passwords do not match';
    return null;
  }

  // Navigates to login page
  void onSignInTapped() {
    navigateToRoute = '/login';
    notifyListeners();
  }

  // Navigates back to splash screen
  void onBackButtonTapped() {
    navigateToRoute = '/splash2';
    notifyListeners();
  }

  // Clears navigation state after routing
  void clearNavigation() {
    navigateToRoute = null;
    notifyListeners();
  }
}
