import 'package:flutter/material.dart';
import 'package:roomantics/services/auth_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool loading = false;
  String? errorMessage;
  String? navigateToRoute;

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

  Future<void> signUp() async {
    // Validate form first
    if (!formKey.currentState!.validate()) {
      return;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signup(
        email: email,
        password: password,
        displayName: name,
      );

      if (result['success'] == true) {
        loading = false;
        navigateToRoute = '/home';
      } else {
        loading = false;
        errorMessage = result['error'] ?? 'Sign up failed. Please try again.';
      }
    } catch (e) {
      loading = false;
      errorMessage = 'An unexpected error occurred. Please try again later.';
      debugPrint('SignUpViewModel signUp error: $e');
    }

    notifyListeners();
  }

  String? nameValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Name required' : null;

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? passwordValidator(String? v) =>
      (v == null || v.length < 6) ? 'Password min 6 characters' : null;

  String? confirmPasswordValidator(String? v) =>
      (v != password) ? 'Passwords do not match' : null;

  void onSignInTapped() {
    navigateToRoute = '/login';
    notifyListeners();
  }

  void onBackButtonTapped() {
    navigateToRoute = '/';
    notifyListeners();
  }

  void clearNavigation() {
    navigateToRoute = null;
    notifyListeners();
  }
}