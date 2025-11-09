import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// EditProfileViewModel
// Handles:
// - Name, Email, Username, Password
// - Profile image selection
// - Form validation
// - Loading & error states
// - Saving updates to SharedPreferences (for AccountHub)
//
// TODO: Replace SharedPreferences logic with actual backend API calls:
//
// 1. GET /user/profile
//    - Fetch current user data (name, email, username, profile image)
//    - Should replace loadUserProfile() logic
//
// 2. PUT /user/profile
//    - Update user details: name, email, username, password
//    - Should replace saveProfile() logic for text fields
//
// 3. POST /user/profile/image
//    - Upload new profile picture and return URL
//    - Should replace saveProfile() logic for profile image
//
// Notes:
// - Current implementation uses SharedPreferences as a temporary placeholder
// - All setters call notifyListeners() to update UI
// - Password is never loaded from local storage
// - Once backend is ready, remove SharedPreferences logic entirely

class EditProfileViewModel extends ChangeNotifier {
  // Form Fields
  String _name = '';
  String _email = '';
  String _username = '';
  String _password = '';

  // Profile Image
  File? _localImage; // Selected from device
  String _profileImageUrl =
      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y'; // Default fallback

  // UI State
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get name => _name;
  String get email => _email;
  String get username => _username;
  String get password => _password;
  File? get localImage => _localImage;
  String get profileImageUrl => _profileImageUrl;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  // Set selected image (from camera or gallery)
  // TODO: Implement backend upload (POST /user/profile/image)
  void setProfileImage(File image) {
    _localImage = image;
    notifyListeners();
  }

  // Toggles password visibility in UI
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Form Validation
  bool validateForm() {
    if (_name.isEmpty || _email.isEmpty || _username.isEmpty) {
      _errorMessage = "Name, Email, and Username cannot be empty.";
      notifyListeners();
      return false;
    }

    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(_email)) {
      _errorMessage = "Please enter a valid email address.";
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // Returns password strength as string: Weak, Medium, Strong
  String passwordStrength() {
    if (_password.length < 6) return "Weak";
    if (_password.length < 10) return "Medium";
    return "Strong";
  }

  // Load User Profile
  /// TODO: Replace SharedPreferences with GET /user/profile API call
  Future<void> loadUserProfile() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved data locally for now
      _name = prefs.getString('user_name') ?? 'Your Name';
      _email = prefs.getString('user_email') ?? 'you@example.com';
      _username = prefs.getString('user_username') ?? 'username';
      _profileImageUrl =
          prefs.getString('profile_image_url') ?? _profileImageUrl;

      _password = ''; // Password should never be loaded
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load profile.";
      debugPrint('Error loading profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save Profile
  // TODO: Replace SharedPreferences with:
  //       PUT /user/profile → update name, email, username, password
  //       POST /user/profile/image → upload profile image
  Future<void> saveProfile() async {
    if (!validateForm()) return;

    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save locally for now (placeholder)
      await prefs.setString('user_name', _name);
      await prefs.setString('user_email', _email);
      await prefs.setString('user_username', _username);

      if (_localImage != null) {
        // Placeholder: save local path; backend should return uploaded URL
        await prefs.setString('profile_image_url', _localImage!.path);
        _profileImageUrl = _localImage!.path; // Update avatar immediately
      }

      _errorMessage = null;
      debugPrint(
          'Profile saved: Name=$_name, Email=$_email, Username=$_username');
    } catch (e) {
      _errorMessage = "Failed to save profile.";
      debugPrint('Error saving profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Internal: update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
