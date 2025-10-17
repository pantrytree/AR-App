import 'package:flutter/foundation.dart';
import 'package:roomantics/services/user_service.dart';
import '/services/auth_service.dart';
import '/utils/text_components.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _successMessage;

  // Form fields
  String _email = '';

  // Step management
  int _currentStep = 0; // 0: Email, 1: Verification

  // Navigation flags
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get email => _email;
  int get currentStep => _currentStep;
  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;

  // Form field setters
  void setEmail(String value) {
    _email = value.trim();
    _clearErrors();
  }

  // ======================
  // BACKEND INTEGRATION
  // ======================

  /// Step 1: Request password reset
  Future<void> sendPasswordResetEmail() async {
    if (!_validateEmailStep()) {
      return;
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // First check if email exists in our user database
      final userExists = await _userService.getUserByEmail(_email);

      if (userExists == null) {
        throw Exception('No account found with this email address. Please check the email or sign up for a new account.');
      }

      // If email exists, send reset password email via Firebase Auth
      final result = await _authService.resetPassword(_email);

      if (result['success'] == true) {
        _successMessage = "Password reset link sent to $_email\n\nPlease check your email and click the link to reset your password. Don't forget to check your spam folder!";
        _currentStep = 1; // Move to verification step
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception(result['error'] ?? 'Failed to send reset email');
      }
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }


  Future<void> verifyResetCompletion() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if password was recently reset using Auth Service
      final wasReset = await _authService.checkRecentPasswordReset(_email);

      if (wasReset) {
        _successMessage = "Password reset successfully! You can now login with your new password.";
        _navigateToRoute = '/login';
        _navigationArguments = {
          'message': 'Password reset successfully! Please login with your new password.',
          'email': _email,
        };
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Password reset not completed yet. Please check your email and click the reset link. Don\'t forget to check your spam folder!');
      }
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ======================
  // VALIDATION METHODS
  // ======================

  bool _validateEmailStep() {
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

  // ======================
  // UI STATE MANAGEMENT
  // ======================

  void goToPreviousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _clearErrors();
      _successMessage = null;
      notifyListeners();
    } else {
      navigateToLogin();
    }
  }

  bool get canGoBack => _currentStep > 0;

  String get currentStepTitle {
    switch (_currentStep) {
      case 0:
        return 'Reset your password';
      case 1:
        return 'Check your email';
      default:
        return 'Reset Password';
    }
  }

  String get currentStepDescription {
    switch (_currentStep) {
      case 0:
        return 'Enter your email address and we\'ll send you a link to reset your password';
      case 1:
        return 'We\'ve sent a password reset link to:\n\n$_email\n\nPlease check your email and click the link to reset your password. Don\'t forget to check your spam folder if you can\'t find it!';
      default:
        return 'Reset your password';
    }
  }

  String get primaryButtonText {
    switch (_currentStep) {
      case 0:
        return 'Send Reset Link';
      case 1:
        return 'Return to Login';
      default:
        return 'Continue';
    }
  }

  // ======================
  // NAVIGATION METHODS
  // ======================

  void navigateToLogin() {
    _navigateToRoute = '/login';
    _navigationArguments = {
      'message': 'Password reset link sent! Please check your email.',
      'email': _email,
    };
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }

  // ======================
  // HELPER METHODS
  // ======================

  void _clearErrors() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = null;
    }
  }

  void resetForm() {
    _email = '';
    _currentStep = 0;
    _hasError = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Resend reset link
  Future<void> resendResetLink() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(_email);

      if (result['success'] == true) {
        _successMessage = 'Reset link sent again to $_email\n\nPlease check your email and spam folder.';
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception(result['error'] ?? 'Failed to resend reset link');
      }
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to resend link: ${e.toString()}';
      notifyListeners();
    }
  }
}