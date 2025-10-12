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
    name = val; // Update the local state
    notifyListeners(); // Notify UI to rebuild with new value
  }

  // Setter for email; called by UI when user types in the email field
  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  // Setter for password; called by UI when user types in the password field
  void setPassword(String val) {
    password = val;
    notifyListeners();
  }

  // Setter for confirmPassword; called by UI when user types in the confirm password field
  void setConfirmPassword(String val) {
    confirmPassword = val;
    notifyListeners();
  }

  // Called when the user taps the sign-up button
  // Handles form validation, simulates a network request, and updates navigation or error state
  Future<void> signUp() async {
    // Validate the form using the formKey; if invalid, exit early
    if (!(formKey.currentState?.validate() ?? false)) return;

    loading = true; // Set loading state to true
    errorMessage = null; // Clear any previous error
    notifyListeners(); // Notify UI to show loading indicator

    try {
      // Simulate a network call (e.g., to a backend API) with a 2-second delay
      await Future.delayed(Duration(seconds: 2));// await _authservice function to import (create user/new user) + parameters (all fields) [for login as well]

      // On success: set loading to false and set navigation route to '/home'
      loading = false;
      navigateToRoute = '/home';
      notifyListeners(); // Notify UI to navigate
    } catch (e) {
      // On error: set loading to false and set an error message
      loading = false;
      errorMessage = 'Failed to sign up. Please try again.';
      notifyListeners(); // Notify UI to show error
    }
  }

  // --- Validation Methods ---

  // Validates the name field; returns error message if invalid, otherwise null
  String? nameValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Name required' : null;

  // Validates the email field; checks for empty and valid email format
  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  // Validates the password field; checks for minimum length
  String? passwordValidator(String? v) =>
      (v == null || v.length < 6) ? 'Password min 6 characters' : null;

  // Validates the confirm password field; checks if it matches the password
  String? confirmPasswordValidator(String? v) =>
      (v != password) ? 'Passwords do not match' : null;

  // --- Navigation Methods ---

  // Called when the user taps 'Sign In' instead; sets navigation route to '/login'
  void onSignInTapped() {
    navigateToRoute = '/login';
    notifyListeners();
  }

  // Called when the user taps the back button; sets navigation route to root ('/')
  void onBackButtonTapped() {
    navigateToRoute = '/';
    notifyListeners();
  }

  // Clears the navigation route after navigation is handled by the UI
  void clearNavigation() {
    navigateToRoute = null;
    notifyListeners();
  }
}
