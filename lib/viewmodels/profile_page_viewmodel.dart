import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '/services/auth_service.dart';
import '/models/user.dart' as models;

class AccountHubViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // User data
  models.User? _currentUser;
  models.User? get currentUser => _currentUser;

  String get userName => _currentUser?.displayName ?? 'User';
  String get email => _currentUser?.email ?? 'user@example.com';
  String? get profileImageUrl => _currentUser?.profileImageUrl;

  // Loading and error states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;


  // Load user data from Firestore
  Future<void> loadUserData() async {
    _setLoading(true);
    _clearMessages();

    try {
      print('Loading user data...');

      _currentUser = await _authService.getCurrentUserModel();

      if (_currentUser == null) {
        _errorMessage = 'Failed to load user profile';
        print('User not found');
      } else {
        print('User loaded: ${_currentUser!.displayName}');
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: ${e.toString()}';
      print('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    print('Refreshing user data...');
    await loadUserData();
  }
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? imageUrl,
  }) async {
    try {
      print('Updating profile...');

      if (name != null && name != _currentUser?.displayName) {
        final result = await _authService.updateDisplayName(name);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update name';
          notifyListeners();
          return false;
        }
      }

      if (email != null && email != _currentUser?.email) {
        final result = await _authService.updateEmail(email);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update email';
          notifyListeners();
          return false;
        }
      }

      if (imageUrl != null && imageUrl != _currentUser?.profileImageUrl) {
        final result = await _authService.updatePhotoURL(imageUrl);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update photo';
          notifyListeners();
          return false;
        }
      }

      // Refresh user data
      await loadUserData();

      _successMessage = 'Profile updated successfully';
      print('Profile updated');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      print('Error updating profile: $e');
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<bool> logout(BuildContext context) async {
    _setLoading(true);
    _clearMessages();

    try {
      Navigator.pushNamed(context, '/logout');
      return true;
    } catch (e) {
      _errorMessage = 'Failed to initiate logout: $e';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      return {
        'projects': 0,
        'designs': 0,
        'favorites': 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'projects': 0,
        'designs': 0,
        'favorites': 0,
      };
    }
  }

  // Clear messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear success
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
