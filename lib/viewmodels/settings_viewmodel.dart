import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingsViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Navigation
  String? _navigateToRoute;
  String? get navigateToRoute => _navigateToRoute;

  // User data
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String? _profileImageUrl;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get profileImageUrl => _profileImageUrl;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  SettingsViewModel() {
    _loadUserData();
  }

  // Load user data from backend
  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Set basic info from Firebase Auth
      _userName = user.displayName ?? 'User';
      _userEmail = user.email ?? 'No email';
      _profileImageUrl = user.photoURL;

      // Load additional data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _userName = data['displayName'] as String? ?? _userName;
        _profileImageUrl = data['photoUrl'] as String? ?? _profileImageUrl;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  // Clear cache functionality
  Future<bool> clearCache() async {
    try {
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      await _clearSharedPreferences();
      await _clearTemporaryFiles();
      await _clearImageCache();
      await _clearFirestoreCache();

      _successMessage = 'Cache cleared successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to clear cache: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear SharedPreferences cache
  Future<void> _clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final keysToKeep = [
        'user_uid',
        'theme_mode',
        'language',
      ];

      final allKeys = prefs.getKeys();
      for (String key in allKeys) {
        if (!keysToKeep.contains(key)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing SharedPreferences: $e');
    }
  }

  // Clear temporary files
  Future<void> _clearTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await _deleteDirectory(tempDir);
      }
    } catch (e) {
      print('Error clearing temporary files: $e');
    }
  }

  // Clear image cache
  Future<void> _clearImageCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final imageCacheDir = Directory('${cacheDir.path}/image_cache');

      if (await imageCacheDir.exists()) {
        await _deleteDirectory(imageCacheDir);
      }

      final libCachedImagesDir = Directory('${cacheDir.path}/libCachedImageData');
      if (await libCachedImagesDir.exists()) {
        await _deleteDirectory(libCachedImagesDir);
      }
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  // Clear Firestore cache (offline data)
  Future<void> _clearFirestoreCache() async {
    try {
      await _firestore.clearPersistence();
    } catch (e) {
      print('Error clearing Firestore cache: $e');
    }
  }

  // Helper method to delete directory recursively
  Future<void> _deleteDirectory(Directory directory) async {
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true)) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Error deleting directory ${directory.path}: $e');
    }
  }

  // Get cache size (for displaying to user)
  Future<String> getCacheSize() async {
    try {
      int totalSize = 0;

      // Calculate temporary files size
      final tempDir = await getTemporaryDirectory();
      totalSize += await _getDirectorySize(tempDir);

      // Format the size
      if (totalSize < 1024) {
        return '${totalSize}B';
      } else if (totalSize < 1024 * 1024) {
        return '${(totalSize / 1024).toStringAsFixed(1)}KB';
      } else {
        return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper to calculate directory size
  Future<int> _getDirectorySize(Directory directory) async {
    try {
      if (!await directory.exists()) return 0;

      int size = 0;
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          size += stat.size;
        }
      }
      return size;
    } catch (e) {
      return 0;
    }
  }

  // Delete account functionality
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'No user logged in';
        notifyListeners();
        return false;
      }

      await _firestore.collection('users').doc(user.uid).delete();
      await _deleteUserSubcollections(user.uid);
      await user.delete();
      await clearCache();

      _successMessage = 'Account deleted successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete account: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete user's subcollections
  Future<void> _deleteUserSubcollections(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // List of subcollections to delete
      final subcollections = ['sessions', 'favorites', 'projects', 'recently_viewed'];

      for (final collection in subcollections) {
        final snapshot = await userRef.collection(collection).get();
        final batch = _firestore.batch();

        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }
    } catch (e) {
      print('Error deleting subcollections: $e');
    }
  }

  // Navigation methods
  void navigateToProfile() {
    _navigateToRoute = '/account-hub';
    notifyListeners();
  }

  void navigateToLanguage() {
    _navigateToRoute = '/language';
    notifyListeners();
  }

  void navigateToNotifications() {
    _navigateToRoute = '/notifications';
    notifyListeners();
  }

  void navigateToChangePassword() {
    _navigateToRoute = '/change-password';
    notifyListeners();
  }

  void navigateToTwoFactorAuth() {
    _navigateToRoute = '/two-factor-auth';
    notifyListeners();
  }

  void navigateToActiveSessions() {
    _navigateToRoute = '/active-sessions';
    notifyListeners();
  }

  void navigateToAbout() {
    _navigateToRoute = '/about';
    notifyListeners();
  }

  void navigateToHelp() {
    _navigateToRoute = '/help';
    notifyListeners();
  }

  void navigateToPrivacyPolicy() {
    _navigateToRoute = '/privacy-policy';
    notifyListeners();
  }

  void navigateToTermsOfService() {
    _navigateToRoute = '/terms-of-service';
    notifyListeners();
  }

  void navigateToLogout() {
    _navigateToRoute = '/logout';
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadUserData();
    clearMessages();
  }

  @override
  void dispose() {
    super.dispose();
  }
}