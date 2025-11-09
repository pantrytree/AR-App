import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '/services/api_service.dart';
import '/models/user.dart' as models;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

  firebase_auth.User? get currentUser => _auth.currentUser;
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
  Future<String?> getIdToken() async => await _auth.currentUser?.getIdToken();
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<models.User?> getCurrentUserModel({bool refresh = false}) async {
    try {
      final uid = _auth.currentUser?.uid;
      print('Getting user model for UID: $uid, refresh: $refresh');

      if (uid == null) {
        print('No current user UID');
        return null;
      }

      if (refresh) {
        // Force refresh Firebase Auth user
        await _auth.currentUser?.reload();
        print('Firebase Auth user reloaded');
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        print('User document does not exist in Firestore');
        return null;
      }

      print('User document found, parsing...');
      final user = models.User.fromFirestore(doc);
      print('User model loaded: ${user.displayName}, Photo: ${user.photoUrl}');
      return user;

    } catch (e) {
      print('Error getting current user model: $e');
      return null;
    }
  }

  Stream<models.User?> streamCurrentUserModel() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return models.User.fromFirestore(doc);
    });
  }

  Future<models.User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      try {
        await _apiService.post(
          '/auth/login',
          body: {'uid': credential.user!.uid},
          requiresAuth: true,
        );
      } catch (apiError) {
        print('Backend login notification failed: $apiError');
      }
      final userModel = await getCurrentUserModel();

      return userModel;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': null,
        'preferences': {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      try {
        await _apiService.post(
          '/auth/signup',
          body: {
            'email': email,
            'password': password,
            'displayName': displayName,
          },
        );
        print('Backend user registration completed');
      } catch (apiError) {
        print('Backend registration failed (non-critical): $apiError');
      }

      final userModel = await getCurrentUserModel();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}');
      return false;
    } catch (e) {
      print('Unexpected Error: $e');
      return false;
    }
  }

  // Forgot Password
  // Endpoint: POST /api/auth/forgot-password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      try {
        await _apiService.post(
          '/auth/forgot-password',
          body: {'email': email},
        );
      } catch (apiError) {
        print('Backend notification failed (non-critical): $apiError');
      }

      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Error: ${e.code}');
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      print('Unexpected Error: $e');
      return {
        'success': false,
        'error': 'Failed to send reset email',
      };
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

// Update email
  Future<Map<String, dynamic>> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      print('Updating email from ${user.email} to $newEmail');

      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(newEmail)) {
        return {
          'success': false,
          'error': 'Invalid email format',
        };
      }

      await user.verifyBeforeUpdateEmail(newEmail);

      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Email updated successfully');

      return {
        'success': true,
        'message': 'Email updated successfully',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code}');
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'error': 'Failed to update email',
      };
    }
  }

  // Update Password
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password updated successfully',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update password',
      };
    }
  }

  Future<bool> checkRecentPasswordReset(String email) async {
    try {
      final resetQuery = await _firestore
          .collection('password_resets')
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThan:
      DateTime.now().subtract(const Duration(minutes: 5)))
          .limit(1)
          .get();

      return resetQuery.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Reauthenticate User
  Future<Map<String, dynamic>> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      return {
        'success': true,
        'message': 'Re-authentication successful',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Re-authentication failed',
      };
    }
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      final uid = user.uid;

      await _deleteUserData(uid);

      await user.delete();

      print('Account deleted successfully');

      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return {
          'success': false,
          'error': 'Please log in again before deleting your account',
          'requiresReauth': true,
        };
      }
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete account',
      };
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(uid).delete();

      // Delete user's projects
      final projectsSnapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in projectsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's designs
      final designsSnapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in designsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user's subcollections (favorites, recently_viewed)
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();

      for (var doc in favoritesSnapshot.docs) {
        await doc.reference.delete();
      }

      final recentlyViewedSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('recently_viewed')
          .get();

      for (var doc in recentlyViewedSnapshot.docs) {
        await doc.reference.delete();
      }

      print('All user data deleted from Firestore');
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      if (user.emailVerified) {
        return {
          'success': false,
          'error': 'Email is already verified',
        };
      }

      await user.sendEmailVerification();

      return {
        'success': true,
        'message': 'Verification email sent',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to send verification email',
      };
    }
  }

  Future<bool> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('Error reloading user: $e');
      return false;
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<Map<String, dynamic>> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      await user.updateDisplayName(displayName);
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Display name updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update display name',
      };
    }
  }

  Future<Map<String, dynamic>> updatePhotoURL(String photoURL) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      await user.updatePhotoURL(photoURL);

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Photo updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update photo',
      };
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'Please log in again to complete this action.';
      case 'invalid-credential':
        return 'The supplied credential is invalid.';
      case 'email-already-exists':
        return 'The email address is already in use.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

}
