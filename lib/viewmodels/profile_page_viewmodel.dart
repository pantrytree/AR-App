import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AccountHubViewModel
//
// Handles user data management for the Account Hub screen.
//
// Features:
// - Loads user data from local storage (SharedPreferences)
// - Updates profile info (name, email, username, image)
// - Provides live refresh when returning from Edit Profile
// - Prepared for backend integration with TODOs
//
// Backend APIs to implement:
// 1. GET /user/profile
//    - Load user info (name, email, username, profile image)
//    - Should replace loadUserData()
// 2. PUT /user/profile
//    - Update user details (name, email, username)
//    - Should replace updateProfile() logic for text fields
// 3. POST /user/profile/image
//    - Upload new profile picture
//    - Should replace updateProfile() logic for profileImageUrl
// 4. POST /auth/logout (or DELETE /user/session)
//    - Invalidate user session / auth token
//    - Should replace logout() logic
class AccountHubViewModel extends ChangeNotifier {
  // User Data
  String _userName = '';
  String _email = '';
  String _username = '';
  String _profileImageUrl =
      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';
  bool _isLoading = true;

  // Getters
  String get userName => _userName;
  String get email => _email;
  String get username => _username;
  String get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;

  // SharedPreferences keys — can be removed when backend is ready
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _usernameKey = 'user_username';
  static const String _imageKey = 'profile_image_url';

  // Load user data
  // Loads user data from SharedPreferences (placeholder for backend)
  // TODO: Replace with GET /user/profile API call
  Future<void> loadUserData() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      _userName = prefs.getString(_nameKey) ?? 'Your Name';
      _email = prefs.getString(_emailKey) ?? 'you@example.com';
      _username = prefs.getString(_usernameKey) ?? 'username';
      _profileImageUrl = prefs.getString(_imageKey) ?? _profileImageUrl;

      // TODO: Once backend API is ready, replace this logic
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  // Refreshes data manually when returning from Edit Profile
  // TODO: Ensure this calls GET /user/profile to get latest backend data
  Future<void> refreshUserData() async {
    await loadUserData();
    notifyListeners();
  }

  // Update user profile info
  // Updates local user data and persists to SharedPreferences
  // TODO: Replace with PUT /user/profile and POST /user/profile/image when backend is ready
  Future<void> updateProfile({
    String? name,
    String? email,
    String? username,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null && name.isNotEmpty) {
      _userName = name;
      await prefs.setString(_nameKey, name);
      // TODO: PUT /user/profile → update name on backend
    }

    if (email != null && email.isNotEmpty) {
      _email = email;
      await prefs.setString(_emailKey, email);
      // TODO: PUT /user/profile → update email on backend
    }

    if (username != null && username.isNotEmpty) {
      _username = username;
      await prefs.setString(_usernameKey, username);
      // TODO: PUT /user/profile → update username on backend
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      _profileImageUrl = imageUrl;
      await prefs.setString(_imageKey, imageUrl);
      // TODO: POST /user/profile/image → upload profile image to backend
    }

    notifyListeners();
  }

  // Logout
  // Clears user data and local preferences
  // TODO: Call backend logout API (POST /auth/logout or DELETE /user/session)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset local fields
    _userName = '';
    _email = '';
    _username = '';
    _profileImageUrl =
    'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';

    notifyListeners();
  }

  // Internal helper
  // Sets loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
