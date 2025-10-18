import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/auth_service.dart';
import '/services/api_service.dart';

class ChangePasswordViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validate password strength
      final passwordValidation = _validatePasswordStrength(newPassword);
      if (passwordValidation != null) {
        _errorMessage = passwordValidation;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('Re-authenticating user...');
      final reauthResult = await _reauthenticateUser(currentPassword);
      if (!reauthResult) {
        _errorMessage = 'Current password is incorrect.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('Updating password in Firebase Auth...');
      await user.updatePassword(newPassword);

      print('Updating password record in Firestore...');
      await _updatePasswordInFirestore(user.uid, newPassword);

      print('Notifying backend API...');
      await _notifyBackendPasswordChange(user.uid, newPassword);

      await _logPasswordChange(user.uid);

      _successMessage = 'Password changed successfully!';
      _isLoading = false;
      notifyListeners();

      return true;

    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to change password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Re-authenticate user with current password
  Future<bool> _reauthenticateUser(String currentPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Re-authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Re-authentication unexpected error: $e');
      return false;
    }
  }

  /// Update password record in Firestore for audit trail
  Future<void> _updatePasswordInFirestore(String userId, String newPassword) async {
    try {
      final passwordData = {
        'passwordLastChanged': FieldValue.serverTimestamp(),
        'passwordChangedAt': DateTime.now().toIso8601String(),
        'passwordChangeCount': FieldValue.increment(1),
      };

      await _firestore.collection('users').doc(userId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        ...passwordData,
      });

      await _firestore.collection('password_changes').add({
        'userId': userId,
        'changedAt': FieldValue.serverTimestamp(),
        'changeType': 'manual_update',
        'ipAddress': 'unknown',
        'deviceInfo': 'mobile_app',
      });

      print('Password updated in Firestore successfully');
    } catch (e) {
      print('Error updating password in Firestore: $e');
    }
  }

  /// Notify backend API about password change
  Future<void> _notifyBackendPasswordChange(String userId, String newPassword) async {
    try {
      final response = await _apiService.post(
        '/auth/change-password',
        body: {
          'userId': userId,
          'passwordChangedAt': DateTime.now().toIso8601String(),
        },
        requiresAuth: true,
      );

      if (response['success'] != true) {
        print('Backend notification failed: ${response['error']}');
      } else {
        print('Backend notified successfully');
      }
    } catch (e) {
      print('Error notifying backend: $e');
    }
  }

  /// Log password change for security audit
  Future<void> _logPasswordChange(String userId) async {
    try {
      await _firestore.collection('security_logs').add({
        'userId': userId,
        'action': 'password_change',
        'timestamp': FieldValue.serverTimestamp(),
        'description': 'User changed their password',
        'severity': 'medium',
        'ipAddress': 'mobile_app',
        'userAgent': 'Roomantics Mobile App',
      });
    } catch (e) {
      print('Error logging password change: $e');
    }
  }

  /// Validate password strength
  String? _validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    // Check for common passwords (basic check)
    final commonPasswords = [
      'password', '123456', '12345678', '123456789', 'qwerty',
      'abc123', 'password1', '12345', '1234567', '111111'
    ];
    if (commonPasswords.contains(password.toLowerCase())) {
      return 'This password is too common. Please choose a stronger password.';
    }

    return null;
  }

  /// Check if user can change password (rate limiting, etc.)
  Future<Map<String, dynamic>> canChangePassword() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return {'canChange': false, 'reason': 'User not authenticated'};
      }

      final lastChanges = await _firestore
          .collection('password_changes')
          .where('userId', isEqualTo: user.uid)
          .where('changedAt', isGreaterThan: DateTime.now().subtract(Duration(hours: 1)))
          .get();

      if (lastChanges.docs.length >= 3) {
        return {
          'canChange': false,
          'reason': 'Too many password changes recently. Please try again in an hour.'
        };
      }

      return {'canChange': true};
    } catch (e) {
      return {'canChange': true};
    }
  }

  /// Handle Firebase Auth specific errors
  String _handleFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The new password is too weak. Please choose a stronger password.';
      case 'requires-recent-login':
        return 'For security reasons, please log in again before changing your password.';
      case 'user-not-found':
        return 'User account not found. Please log in again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Password change is not allowed. Please contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your current password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred: ${e.message ?? 'Please try again.'}';
    }
  }

  /// Send password change confirmation email
  Future<void> sendPasswordChangeConfirmation() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user?.email != null) {
        // You can integrate with your email service here
        // For example, send an email via your backend API
        await _apiService.post(
          '/notifications/password-changed',
          body: {
            'email': user!.email,
            'timestamp': DateTime.now().toIso8601String(),
            'device': 'mobile_app',
          },
          requiresAuth: true,
        );
      }
    } catch (e) {
      print('Error sending password change confirmation: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Reset view model state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}