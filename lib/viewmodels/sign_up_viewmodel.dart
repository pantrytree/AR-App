//All API calls name 'fakeApiSignUp' to be replaced by real API calls

import 'package:flutter/material.dart';

// ViewModel for the Sign Up screen, extends ChangeNotifier to allow UI updates when state changes
class SignUpViewModel extends ChangeNotifier {
  // Key to uniquely identify the form and access its state (e.g., for validation)
  final formKey = GlobalKey<FormState>();

  // User input fields, updated by the UI via setter methods
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  // Indicates if a sign-up operation is in progress (used to show loading spinners)
  bool loading = false;

  // Holds error messages to display in the UI if sign-up fails
  String? errorMessage;

  // Holds the route name to navigate to after certain actions (e.g., successful sign-up)
  String? navigateToRoute;

  // Setter for name; called by UI when user types in the name field
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

  // Called when the user taps the sign-up button
  // Handles form validation, simulates a network request, and updates navigation or error state
  Future<void> signUp() async {
    // Validate the form using the formKey; if invalid, exit early
    if (!(formKey.currentState?.validate() ?? false)) return;

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // ===== Placeholder for real API/database call =====
      // Replace this with your actual API method
      final bool success = await fakeApiSignUp(name, email, password, confirmPassword);
      // ================================================

      if (success) {
        loading = false;
        navigateToRoute = '/home'; // Navigate on success
      } else {
        loading = false;
        errorMessage = 'Sign up failed. Please try again.';
      }
      notifyListeners();
    } catch (e) {
      loading = false;
      errorMessage = 'Failed to sign up. Please try again.';
      notifyListeners();
    }
  }

  // --- Validation Methods ---

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

  // --- Navigation Methods ---

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

  /// --- Placeholder function simulating an API/database call ---
  /// In production, replace with real HTTP/database call
  Future<bool> fakeApiSignUp(String name, String email, String password, String confirmPassword) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network latency

    // DEMO: Only accept a sample hardcoded user
    if (email == 'newuser@example.com' && password == 'password123' && password == confirmPassword) {
      return true; // Simulate success
    }
    return false; // Simulate failure
  }
}
