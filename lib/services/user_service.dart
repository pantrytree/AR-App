import '/services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:roomantics/models/user.dart' as models;

class UserService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get User Profile
  // Endpoint: GET /api/users/profile
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

  Future<models.User?> getUserProfileById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      return models.User.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

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

  // 2. Update User Profile
  // Endpoint: PUT /api/users/profile
  Future<void> updateUserProfile({
    String? displayName,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (preferences != null) updates['preferences'] = preferences;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

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

  // 3. Get User Preferences
  // Endpoint: GET /api/users/preferences
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

  // 4. Update User Preferences
  // Endpoint: PUT /api/users/preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      // Update in Firestore
      await _firestore.collection('users').doc(uid).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _apiService.put(
        '/users/preferences',
        body: preferences,
        requiresAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

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

  Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

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

  Future<List<models.User>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      List<models.User> users = [];

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

  Future<void> deleteUserAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(uid).delete();

      await _auth.currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}