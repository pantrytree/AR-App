import 'package:flutter/foundation.dart';
import 'dart:io';


/// Handles:
/// - Form fields: name, email, username, password
/// - Profile image upload
/// - Password visibility toggle
/// - Form validation
/// - Loading & error states
/// - Communication with backend

/// Example API endpoints to integrate later:
///   - GET    /user/profile         → Fetch current user's profile
///   - PUT    /user/profile         → Update profile info (name, email, username, password)
///   - POST   /user/profile/image   → Upload a new profile image
///   - DELETE /user/profile/image   → Remove profile image (optional)
class EditProfileViewModel extends ChangeNotifier {
  // Form Fields
  String _name = '';
  String _email = '';
  String _username = '';
  String _password = '';

  // Profile Image
  File? _profileImage;

  // Password Visibility
  bool _obscurePassword = true;

  // Loading & Error State
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get name => _name;
  String get email => _email;
  String get username => _username;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;
  File? get profileImage => _profileImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  /// Updates the user's name and notifies listeners
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  /// Updates the user's email and notifies listeners
  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  /// Updates the user's username and notifies listeners
  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  /// Updates the user's password and notifies listeners
  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  /// Sets a new profile image and notifies listeners
  /// TODO: Integrate POST /user/profile/image API to upload the image
  void setProfileImage(File image) {
    _profileImage = image;
    notifyListeners();
  }

  /// Toggles the password visibility in the UI
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Validation
  /// Validates the form fields before saving
  /// Checks for empty name, email, username and valid email format
  /// Sets [_errorMessage] if invalid
  /// Returns true if the form is valid
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

    _errorMessage = null; // Clear previous errors if valid
    notifyListeners();
    return true;
  }

  /// Returns a string representing password strength: Weak, Medium, Strong
  /// Can be used to show a visual indicator in the UI
  String passwordStrength() {
    if (_password.length < 6) return "Weak";
    if (_password.length < 10) return "Medium";
    return "Strong";
  }

  // Load Profile
  /// Loads the current user profile from backend (placeholder for now)
  /// TODO: Replace placeholder logic with GET /user/profile
  /// Sets the form fields and profile image
  Future<void> loadUserProfile() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulate API delay

      // Placeholder data
      _name = "Shae Fonda";
      _email = "shae@example.com";
      _username = "shaeFonda";
      _password = "";
      _profileImage = null;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load profile.";
      debugPrint('EditProfileViewModel.loadUserProfile error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save Profile
  /// Saves changes made to the profile
  /// Performs form validation first
  /// TODO: Replace placeholder logic with:
  ///       PUT /user/profile → update name, email, username, password
  ///       POST /user/profile/image → upload profile image if changed
  /// Updates [_errorMessage] if saving fails
  Future<void> saveProfile() async {
    if (!validateForm()) return;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 2)); // simulate API call

      debugPrint("Profile saved:");
      debugPrint("Name: $_name");
      debugPrint("Email: $_email");
      debugPrint("Username: $_username");
      debugPrint("Password: $_password");
      if (_profileImage != null) debugPrint("Profile Image: ${_profileImage!.path}");

      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to save profile.";
      debugPrint('EditProfileViewModel.saveProfile error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Internal Helper
  /// Sets the loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
