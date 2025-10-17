// viewmodels/edit_profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/cloudinary_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // User data
  String _name = '';
  String _email = '';
  String? _profileImageUrl;
  File? _profileImage;

  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  String get name => _name;
  String get email => _email;
  String? get profileImageUrl => _profileImageUrl;
  File? get profileImage => _profileImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Load user profile from backend
  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        _name = data['displayName'] as String? ?? user.displayName ?? '';
        _email = data['email'] as String? ?? user.email ?? '';
        _profileImageUrl = data['photoUrl'] as String? ?? user.photoURL;
      } else {
        // Fallback to Auth user data
        _name = user.displayName ?? '';
        _email = user.email ?? '';
        _profileImageUrl = user.photoURL;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _profileImage = File(image.path);
        // Clear the old URL since we have a new local image
        _profileImageUrl = null;
        notifyListeners();

        _successMessage = 'Image selected. Click Save to update your profile.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        _profileImage = File(image.path);
        // Clear the old URL since we have a new local image
        _profileImageUrl = null;
        notifyListeners();

        _successMessage = 'Image captured. Click Save to update your profile.';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to capture image: $e';
      notifyListeners();
    }
  }

  // Delete profile image
  Future<void> deleteProfileImage() async {
    try {
      _profileImage = null;
      _profileImageUrl = null;
      notifyListeners();

      _successMessage = 'Profile image removed. Click Save to update your profile.';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove image: $e';
      notifyListeners();
    }
  }

  // Save profile to backend
  Future<bool> saveProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String? newImageUrl = _profileImageUrl;

      // Upload new image if selected
      if (_profileImage != null) {
        newImageUrl = await _uploadProfileImage(_profileImage!, user.uid);
        if (newImageUrl == null) {
          _errorMessage = 'Failed to upload profile image';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        print('New image URL from Cloudinary: $newImageUrl');
      }

      // Update Firebase Auth first (this usually works even with App Check issues)
      try {
        await user.updateDisplayName(_name);
        if (newImageUrl != null) {
          await user.updatePhotoURL(newImageUrl);
          print('Updated Firebase Auth photo URL: $newImageUrl');
        } else if (_profileImage == null && _profileImageUrl == null) {
          await user.updatePhotoURL(null);
          print('Cleared Firebase Auth photo URL');
        }
      } catch (e) {
        print('Error updating Firebase Auth: $e');
        // Continue with Firestore update even if Auth fails
      }

      // Update Firestore with retry logic
      bool firestoreUpdated = false;
      try {
        final updateData = <String, dynamic>{
          'displayName': _name,
          'email': _email,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Only update photoUrl if we have a new one or if it was deleted
        if (_profileImage != null) {
          updateData['photoUrl'] = newImageUrl;
          print('Setting Firestore photoUrl to: $newImageUrl');
        } else if (_profileImage == null && _profileImageUrl == null) {
          // User removed the image
          updateData['photoUrl'] = null;
          print('Clearing Firestore photoUrl');
        }

        await _firestore.collection('users').doc(user.uid).set(
          updateData,
          SetOptions(merge: true),
        );
        firestoreUpdated = true;
        print('Firestore updated successfully');
      } catch (e) {
        print('Error updating Firestore: $e');
        // Don't fail completely if Firestore has issues
      }

      // Refresh the local data with updated values
      _profileImageUrl = newImageUrl;
      _profileImage = null; // Clear the local file after successful upload

      // Force a UI refresh
      await loadUserProfile(); // Reload from backend to ensure consistency

      _isLoading = false;

      if (firestoreUpdated) {
        _successMessage = 'Profile updated successfully!';
      } else {
        _successMessage = 'Profile updated (some data may sync later)';
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to save profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Upload profile image to Cloudinary or your storage service
  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    try {
      // Use your existing CloudinaryService
      final cloudinaryService = CloudinaryService();

      // Upload to Cloudinary using your existing method
      final imageUrl = await cloudinaryService.uploadProfileImageUnsigned(
          imageFile,
          userId
      );

      print('Profile image uploaded to Cloudinary: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading profile image to Cloudinary: $e');
      _errorMessage = 'Failed to upload profile image: $e';
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}