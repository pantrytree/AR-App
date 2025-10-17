import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/services/auth_service.dart';

class NotificationsViewModel with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _projectUpdates = true;
  bool _promotional = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get projectUpdates => _projectUpdates;
  bool get promotional => _promotional;

  NotificationsViewModel() {
    _loadNotificationSettings();
  }

  // Load notification settings from Firestore
  Future<void> _loadNotificationSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUserModel();

      if (user?.preferences != null) {
        final notifications = user!.preferences?['notifications'] as Map<String, dynamic>?;

        if (notifications != null) {
          _pushNotifications = notifications['push'] ?? true;
          _emailNotifications = notifications['email'] ?? false;
          _smsNotifications = notifications['sms'] ?? false;
          _projectUpdates = notifications['projectUpdates'] ?? true;
          _promotional = notifications['promotional'] ?? false;
        }
      }

      print('Notification settings loaded');
    } catch (e) {
      print('Error loading notification settings: $e');
      _errorMessage = 'Failed to load notification settings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update individual notification setting
  void updatePushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  void updateEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  void updateSmsNotifications(bool value) {
    _smsNotifications = value;
    notifyListeners();
  }

  void updateProjectUpdates(bool value) {
    _projectUpdates = value;
    notifyListeners();
  }

  void updatePromotional(bool value) {
    _promotional = value;
    notifyListeners();
  }

  // Save all notification settings to Firestore
  Future<bool> saveNotificationSettings() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final notificationPreferences = {
        'notifications': {
          'push': _pushNotifications,
          'email': _emailNotifications,
          'sms': _smsNotifications,
          'projectUpdates': _projectUpdates,
          'promotional': _promotional,
          'updatedAt': DateTime.now().toIso8601String(),
        }
      };

      // Save to Firestore via UserService
      await _userService.updateUserPreferences(notificationPreferences);

      _successMessage = 'Notification settings saved successfully';
      print('Notification settings saved to Firestore');
      return true;
    } catch (e) {
      print('Error saving notification settings: $e');
      _errorMessage = 'Failed to save notification settings';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Refresh settings
  Future<void> refresh() async {
    await _loadNotificationSettings();
  }
}