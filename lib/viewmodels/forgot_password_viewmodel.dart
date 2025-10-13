import 'package:flutter/foundation.dart';
import '/utils/text_components.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _successMessage;

  // Form field
  String _email = '';

  // Navigation flags
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get email => _email;
  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;

  // Form field setters
  void setEmail(String value) {
    _email = value.trim();
    _clearErrors();
  }

  //sends reset email
  Future<void> sendPasswordResetEmail() async {
    if (!_validateForm()) {
      return;
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // TODO: Backend - Implement AuthService.sendPasswordResetEmail()
      // This should call: POST /api/auth/forgot-password
      // Request body: {"email": _email}
      // Response format: { "message": "Reset link sent successfully" }

      // Mock implementation for now
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Simulate successful response
      _successMessage = "Password reset link sent to $_email";
      _isLoading = false;
      notifyListeners();

      // Optionally navigate back to login after success
      // _navigateToRoute = '/login';
      // notifyListeners();

    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to send reset link: ${e.toString()}';
      notifyListeners();
    }
  }

  //checks reset code (for future use)
  Future<void> validateResetCode(String resetCode) async {
    // TODO: Backend - Implement AuthService.validateResetCode()
    // This should call: POST /api/auth/validate-reset-code
    // Request body: {"email": _email, "reset_code": resetCode}

    // For now, this is a placeholder for future implementation
  }

  //updates password after reset (for future use)
  Future<void> updateNewPassword(String newPassword, String confirmPassword) async {
    // TODO: Backend - Implement AuthService.updatePassword()
    // This should call: POST /api/auth/reset-password
    // Request body: {"email": _email, "new_password": newPassword, "reset_token": "token"}

    // For now, this is a placeholder for future implementation
  }

  // Navigation methods
  void navigateToLogin() {
    _navigateToRoute = '/login';
    _navigationArguments = null;
    notifyListeners();
  }

  void navigateToSignUp() {
    _navigateToRoute = '/signup';
    _navigationArguments = null;
    notifyListeners();
  }

  // Clear navigation flags
  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }

  // Helper methods
  bool _validateForm() {
    if (_email.isEmpty) {
      _hasError = true;
      _errorMessage = TextComponents.emailRequired;
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(_email)) {
      _hasError = true;
      _errorMessage = TextComponents.invalidEmail;
      notifyListeners();
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _clearErrors() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = null;
    }
  }

  // Reset form
  void resetForm() {
    _email = '';
    _hasError = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}