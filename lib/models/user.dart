import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.preferences,
  });

  // From JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
      lastLogin: json['lastLogin'] != null
          ? _parseDateTime(json['lastLogin'])
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  // From Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      profileImageUrl: data['profileImageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      preferences: data['preferences'] as Map<String, dynamic>?,
    );
  }

  // From Firestore Map (subcollection)
  factory User.fromFirestoreMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      profileImageUrl: data['profileImageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      preferences: data['preferences'] as Map<String, dynamic>?,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'preferences': preferences,
    };
  }

  // To Firestore (for Firestore writes)
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'preferences': preferences ?? {},
    };
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    }
    throw ArgumentError('Invalid date format');
  }

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() => 'User(uid: $uid, email: $email, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}