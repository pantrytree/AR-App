import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> logoutUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'No user is currently logged in';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('Logging out user: ${user.uid}');

      // 1. Clear current session from Firestore
      await _clearCurrentSession(user.uid);

      // 2. Clear local storage
      await _clearLocalData();

      // 3. Sign out from Firebase Auth
      await _auth.signOut();

      print('User logged out successfully');

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      print('Error during logout: $e');
      _errorMessage = 'Failed to logout: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _clearCurrentSession(String userId) async {
    try {
      final currentSessionId = _getCurrentSessionId();
      if (currentSessionId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('sessions')
            .doc(currentSessionId)
            .delete();

        print('Cleared current session: $currentSessionId');
      }
    } catch (e) {
      print('Error clearing session: $e');
    }
  }

  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final keysToKeep = ['theme_mode']; // Keep theme preference
      final allKeys = prefs.getKeys();

      for (String key in allKeys) {
        if (!keysToKeep.contains(key)) {
          await prefs.remove(key);
        }
      }

      print('Cleared local storage data');
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  String? _getCurrentSessionId() {
    return 'current_session_${_auth.currentUser?.uid}';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}