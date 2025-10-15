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
    loading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1)); // Optional: show loading spinner

    loading = false;
    navigateToRoute = '/home';
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