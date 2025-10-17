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
    loading = true;
    errorMessage = null;
    notifyListeners();

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
    navigateToRoute = '/splash2';
    notifyListeners();
  }

  void clearNavigation() {
    navigateToRoute = null;
    notifyListeners();
  }
}