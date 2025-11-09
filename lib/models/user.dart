import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final List<String> projectIds;
  final List<String> favoriteIds;
  final List<String> collaborationIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.projectIds = const [],
    this.favoriteIds = const [],
    this.collaborationIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

 // Creates a User instance from a Firestore document snapshot
 // Includes null safety checks and default values for missing data
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      // Convert list fields with empty list fallbacks
      projectIds: List<String>.from(data['projectIds'] ?? []),
      favoriteIds: List<String>.from(data['favoriteIds'] ?? []),
      collaborationIds: List<String>.from(data['collaborationIds'] ?? []),
      // Convert Firestore Timestamps with current time fallback
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Converts the User instance to a Map for Firestore storage
  // Handles DateTime to Timestamp conversion for database compatibility
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'projectIds': projectIds,
      'favoriteIds': favoriteIds,
      'collaborationIds': collaborationIds,
      // Convert DateTime to Firestore Timestamp for storage
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Creates a new User instance with updated fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? projectIds,
    List<String>? favoriteIds,
    List<String>? collaborationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      projectIds: projectIds ?? this.projectIds,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      collaborationIds: collaborationIds ?? this.collaborationIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Returns a string representation of the user for debugging
  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName)';
  }

  // Two users are considered equal if they have the same ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  // Hash code implementation based on user ID for use in collections
  @override
  int get hashCode => id.hashCode;
}
