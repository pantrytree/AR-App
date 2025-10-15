import 'package:cloud_firestore/cloud_firestore.dart';

enum CollaborationRole {
  owner,
  editor,
  viewer;

  String get value => name;

  static CollaborationRole fromString(String value) {
    return CollaborationRole.values.firstWhere(
          (role) => role.name == value.toLowerCase(),
      orElse: () => CollaborationRole.viewer,
    );
  }
}

class Collaboration {
  final String projectId;
  final String userId;
  final CollaborationRole role;
  final DateTime addedAt;
  final String? invitedBy;

  Collaboration({
    required this.projectId,
    required this.userId,
    required this.role,
    required this.addedAt,
    this.invitedBy,
  });

  // From JSON (API response)
  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      projectId: json['projectId'] as String,
      userId: json['userId'] as String,
      role: CollaborationRole.fromString(json['role'] as String),
      addedAt: _parseDateTime(json['addedAt']),
      invitedBy: json['invitedBy'] as String?,
    );
  }

  // From Firestore DocumentSnapshot
  factory Collaboration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Collaboration(
      projectId: data['projectId'] as String,
      userId: data['userId'] as String,
      role: CollaborationRole.fromString(data['role'] as String),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      invitedBy: data['invitedBy'] as String?,
    );
  }

  // From Firestore Map
  factory Collaboration.fromFirestoreMap(Map<String, dynamic> data) {
    return Collaboration(
      projectId: data['projectId'] as String,
      userId: data['userId'] as String,
      role: CollaborationRole.fromString(data['role'] as String),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      invitedBy: data['invitedBy'] as String?,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'userId': userId,
      'role': role.value,
      'addedAt': addedAt.toIso8601String(),
      'invitedBy': invitedBy,
    };
  }

  // To Firestore (for Firestore writes)
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'userId': userId,
      'role': role.value,
      'addedAt': Timestamp.fromDate(addedAt),
      'invitedBy': invitedBy,
    };
  }

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

  Collaboration copyWith({
    String? projectId,
    String? userId,
    CollaborationRole? role,
    DateTime? addedAt,
    String? invitedBy,
  }) {
    return Collaboration(
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      addedAt: addedAt ?? this.addedAt,
      invitedBy: invitedBy ?? this.invitedBy,
    );
  }

  @override
  String toString() => 'Collaboration(projectId: $projectId, userId: $userId, role: ${role.value})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Collaboration &&
              runtimeType == other.runtimeType &&
              projectId == other.projectId &&
              userId == other.userId;

  @override
  int get hashCode => projectId.hashCode ^ userId.hashCode;
}