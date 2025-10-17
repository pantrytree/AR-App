// services/session_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateSession({
    required String sessionId,
    required String deviceName,
    required String platform,
    String location = 'Unknown',
    String ipAddress = '',
    String userAgent = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .set({
      'deviceName': deviceName,
      'platform': platform,
      'location': location,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'lastActive': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateLastActive(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String sessionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(sessionId)
        .delete();
  }

  Stream<QuerySnapshot> getSessionsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('lastActive', descending: true)
        .snapshots();
  }
}