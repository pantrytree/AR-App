import '/services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Roomantics/models/user.dart' as models;

// Service class for managing user data, profiles, and preferences
class UserService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's complete profile from Firestore
  Future<models.User?> getUserProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      return models.User.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  // Get any user's profile by their user ID
  Future<models.User?> getUserProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      return models.User.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  // Stream that provides real-time updates of the current user's profile
  Stream<models.User?> streamUserProfile() {
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

  // Update specific fields in the user's profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (preferences != null) updates['preferences'] = preferences;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update user profile using a complete User model object
  Future<void> updateUserWithModel(models.User user) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(uid).update({
        ...user.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user preferences from the backend API
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final response = await _apiService.get(
        '/users/preferences',
        requiresAuth: true,
      );
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load preferences: $e');
    }
  }

  // Update user preferences in both Firestore and backend API
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      // Update in Firestore
      await _firestore.collection('users').doc(uid).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Sync with backend API
      await _apiService.put(
        '/users/preferences',
        body: preferences,
        requiresAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  // Update a single preference key-value pair in Firestore
  Future<void> updatePreference(String key, dynamic value) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(uid).update({
        'preferences.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update preference: $e');
    }
  }

  // Update the user's last login timestamp for activity tracking
  Future<void> updateLastLogin() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to update last login: $e');
    }
  }

  // Check if a user exists in the database by their user ID
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Search for users by display name using Firestore query
  Future<List<models.User>> searchUsersByName(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => models.User.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Find a user by their email address
  Future<models.User?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return models.User.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Get multiple users by their IDs using batched queries (10 users per batch)
  Future<List<models.User>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      List<models.User> users = [];

      // Process in batches of 10 due to Firestore 'in' query limitations
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();

        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        users.addAll(
            snapshot.docs.map((doc) => models.User.fromFirestore(doc))
        );
      }

      return users;
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Permanently delete the current user's account and data
  Future<void> deleteUserAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete user from Firebase Authentication
      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
