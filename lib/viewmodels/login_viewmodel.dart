import 'package:flutter/material.dart';

// ViewModel for the Login screen, extends ChangeNotifier to manage and notify UI about state changes
class LoginViewModel extends ChangeNotifier {
  // --- State Variables ---

  // Indicates if a login operation is in progress (used to show loading spinners)
  bool _isLoading = false;

  // Holds error messages to display in the UI if login fails or input is invalid
  String _errorMessage = '';

  // Holds the route name to navigate to after certain actions (e.g., successful login)
  String? _navigateToRoute;

  // --- Controllers for Text Fields ---

  // Used by the UI to read and write the email input field directly
  final emailController = TextEditingController();

  // Used by the UI to read and write the password input field directly
  final passwordController = TextEditingController();

  // --- Getters for State Variables ---

  // Exposes the loading state to the UI
  bool get isLoading => _isLoading;

  // Exposes the error message to the UI
  String get errorMessage => _errorMessage;

  // Exposes the navigation route to the UI
  String? get navigateToRoute => _navigateToRoute;

  // --- Login Logic ---

  // Called when the user taps the login button
  // Handles input validation, simulates a network request, and updates navigation or error state
  void login() async {
    // Get the current values from the text controllers
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validate input fields; if empty, set error message and notify UI
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter email and password';
      notifyListeners(); // UI will show the error message
      return;
    }

    // Set loading state to true and clear previous errors
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // UI will show loading indicator

    try {
      // Simulate a network call (e.g., to a backend API) with a 2-second delay
      await Future.delayed(Duration(seconds: 2));

      // On success: set navigation route to '/home'
      _navigateToRoute = '/home';
      notifyListeners(); // UI will handle navigation
    } catch (e) {
      // On error: set error message from exception
      _errorMessage = e.toString();
      notifyListeners(); // UI will show error message
    } finally {
      // Always set loading to false at the end of the process
      _isLoading = false;
      notifyListeners(); // UI will hide loading indicator
    }
  }

  // --- Navigation Methods ---

  // Called when the user taps 'Sign Up'; sets navigation route to '/signup'
  void onSignUpTapped() {
    _navigateToRoute = '/signup';
    notifyListeners(); // UI will handle navigation
  }

  // Called when the user taps 'Forgot Password'; placeholder for password reset logic or navigation
  void onForgotPasswordTapped() {
    // Example: _navigateToRoute = '/forgot-password';
    notifyListeners(); // UI can respond if implemented
  }

  // Called when the user taps the back button; sets navigation route to root ('/')
  void onBackButtonTapped() {
    _navigateToRoute = '/';
    notifyListeners(); // UI will handle navigation
  }

  // Clears the navigation route after navigation is handled by the UI
  void clearNavigation() {
    _navigateToRoute = null;
    notifyListeners(); // UI will reset navigation state
  }
}
