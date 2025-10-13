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

  // ======================
  // BACKEND INTEGRATION POINTS
  // ======================

  // TODO: Backend - Implement sendPasswordResetEmail()
  // Description: Creates a record in password_resets table and sends email
  // Expected: Returns success message
  Future<void> _sendPasswordResetEmailToBackend() async {
    // Backend team to implement:
    // - Create record in password_resets table
    // - Send actual reset email to user
    // - Return success status
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    return; // Backend should return success response
  }

  // TODO: Backend - Implement validateResetCode()
  // Description: Checks reset code against password_resets table
  // Expected: Returns boolean (valid/invalid)
  Future<bool> _validateResetCodeWithBackend(String resetCode) async {
    // Backend team to implement:
    // - Query password_resets table for valid reset code
    // - Check expiration time
    // - Return validation result
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return true; // Backend should return validation result
  }

  // TODO: Backend - Implement updateNewPassword()
  // Description: Updates user password in users table
  // Expected: Returns success message
  Future<void> _updateNewPasswordInBackend(String newPassword) async {
    // Backend team to implement:
    // - Update password field in users table
    // - Invalidate used reset codes
    // - Return success status
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return; // Backend should return success response
  }

  // ======================
  // PUBLIC METHODS
  // ======================

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
      // Backend team: This function needs implementation
      await _sendPasswordResetEmailToBackend();

      _successMessage = "Password reset link sent to $_email";
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to send reset link: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> validateResetCode(String resetCode) async {
    // Backend team: This function needs implementation
    final isValid = await _validateResetCodeWithBackend(resetCode);
    if (!isValid) {
      throw Exception('Invalid reset code');
    }
  }

  Future<void> updateNewPassword(String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    // Backend team: This function needs implementation
    await _updateNewPasswordInBackend(newPassword);
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

  void resetForm() {
    _email = '';
    _hasError = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}