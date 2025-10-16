import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
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
    if (!(formKey.currentState?.validate() ?? false)) return;

    loading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1)); // Simulate network latency

    // Simulate failure for demonstration
    bool success = false; // Change to your API call result

    if (success) {
      loading = false;
      navigateToRoute = '/home';
    } else {
      loading = false;
      errorMessage = 'Sign up failed. Please try again.';
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

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
