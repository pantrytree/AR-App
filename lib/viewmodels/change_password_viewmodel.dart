import 'package:flutter/material.dart';

class ChangePasswordViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Backend Integration - Replace with actual API call
      // Example expected implementation:
      //
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/change-password'),
      //   headers: {'Authorization': 'Bearer $token'},
      //   body: {
      //     'currentPassword': currentPassword,
      //     'newPassword': newPassword,
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   return true;
      // } else {
      //   _errorMessage = _parseErrorResponse(response.body);
      //   return false;
      // }

      // Mock implementation for frontend development
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      return true;

      // To test error case, uncomment below:
      // _errorMessage = 'Current password is incorrect';
      // return false;

    } catch (e) {
      _errorMessage = 'Network error: Please check your connection';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}