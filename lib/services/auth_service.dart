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

  Future<models.User?> getCurrentUserModel() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return models.User.fromFirestore(doc);
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

  // 1. Log In
  // Endpoint: POST /api/auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final firebase_auth.UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(Duration(milliseconds: 100));

      final firebase_auth.User? currentUser = _auth.currentUser;

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      try {
        await _apiService.post(
          '/auth/login',
          body: {'uid': currentUser?.uid ?? '',},
          requiresAuth: true,
        );
        print('Backend login notification sent');
      } catch (apiError) {
        print('Backend login notification failed (non-critical): $apiError');
      }

      final userModel = await getCurrentUserModel();
      print('DEBUG: userModel type: ${userModel.runtimeType}');

      return {
        'success': true,
        'user': credential.user,
        'userModel': userModel,
        'message': 'Login successful',
      };

    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}');
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      print('Unexpected Error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  // 2. Sign Up
  // Endpoint: POST /api/auth/sign-up
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final firebase_auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);

        // Force reload to get updated user data
        await credential.user!.reload();

        // Get fresh user instance
        final firebase_auth.User? updatedUser = _auth.currentUser;

        print('✅ Display name updated: ${updatedUser?.displayName}');
      }

      // Get ID token
      final String? idToken = await credential.user?.getIdToken();
      final now = DateTime.now();
      final userModel = models.User(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        profileImageUrl: null,
        createdAt: now,
        updatedAt: now,
        lastLogin: now,
        preferences: {},
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

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

      return {
        'success': true,
        'user': credential.user,
        'userModel': userModel,
        'message': 'Account created successfully',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}');
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      print('Unexpected Error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  // 3. Forgot Password
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

  // 4. Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // 5. Update email
  Future<Map<String, dynamic>> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'No user logged in',
        };
      }

      // Update in Firebase Auth
      await user.updateEmail(newEmail);

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Email updated successfully',
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update email',
      };
    }
  }

  //6. Update Password
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

  //7. Reauthenticate User
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

  // 8. Delete Account
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

      // Delete user data from Firestore
      await _deleteUserData(uid);

      // Delete Firebase Auth account
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

      // Update in Firebase Auth
      await user.updateDisplayName(displayName);

      // Update in Firestore
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

      // Update in Firebase Auth
      await user.updatePhotoURL(photoURL);

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': photoURL,
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

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
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