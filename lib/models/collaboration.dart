import 'package:cloud_firestore/cloud_firestore.dart';

// Defines the permission levels for collaborators in a project
enum CollaborationRole {
  owner,    // Full control - can delete project, manage collaborators
  editor,   // Can edit project content and settings  
  viewer,   // Read-only access to project
}

// Represents the current state of a collaboration invitation
enum CollaborationStatus {
  pending,   // Invitation sent but not yet responded to
  accepted,  // Invitation accepted by invitee
  declined,  // Invitation declined by invitee
}

// Represents a collaboration invitation between users for a project
// Manages invitation lifecycle from creation to acceptance/declination
class Collaboration {
  final String id;                    // Firestore document ID
  final String projectId;            // ID of the project being shared
  final String inviterId;            // User ID of the person sending invitation
  final String inviteeId;            // User ID of the person receiving invitation
  final CollaborationRole role;      // Permission level being offered
  final CollaborationStatus status;  // Current state of the invitation
  final DateTime createdAt;          // When the invitation was created
  final DateTime updatedAt;          // Last time the invitation was modified
  final DateTime? acceptedAt;        // When the invitation was accepted 
  final DateTime? declinedAt;       // When the invitation was declined 
  final String? message;             // Optional message from inviter to invitee

  Collaboration({
    required this.id,
    required this.projectId,
    required this.inviterId,
    required this.inviteeId,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.declinedAt,
    this.message,
  });

  // Creates a Collaboration instance from a Firestore document snapshot
  // Handles type conversion from Firestore Timestamp to DateTime
  // Provides fallbacks for enum values to maintain data integrity
  factory Collaboration.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Collaboration(
      id: doc.id,
      projectId: data['projectId'] as String,
      inviterId: data['inviterId'] as String,
      inviteeId: data['inviteeId'] as String,
      // Convert string from Firestore to CollaborationRole enum
      // Default to viewer if role string doesn't match any enum value
      role: CollaborationRole.values.firstWhere(
            (e) => e.name == data['role'],
        orElse: () => CollaborationRole.viewer,
      ),
      // Convert string from Firestore to CollaborationStatus enum  
      // Default to pending if status string doesn't match any enum value
      status: CollaborationStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => CollaborationStatus.pending,
      ),
      // Convert Firestore Timestamp to Dart DateTime
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      // Handle optional timestamp fields that might be null
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      declinedAt: data['declinedAt'] != null
          ? (data['declinedAt'] as Timestamp).toDate()
          : null,
      message: data['message'] as String?,
    );
  }

  // Converts the Collaboration instance to a Map for Firestore storage
  // Handles conversion of DateTime to Firestore Timestamp
  // Stores enum values as their string names for readability
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'inviterId': inviterId,
      'inviteeId': inviteeId,
      'role': role.name,          // Store enum as string
      'status': status.name,      // Store enum as string
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Only include timestamp fields if they have values
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'declinedAt': declinedAt != null ? Timestamp.fromDate(declinedAt!) : null,
      'message': message,
    };
  }

  // Creates a new Collaboration instance with updated fields
  Collaboration copyWith({
    String? id,
    String? projectId,
    String? inviterId,
    String? inviteeId,
    CollaborationRole? role,
    CollaborationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    String? message,
  }) {
    return Collaboration(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      declinedAt: declinedAt ?? this.declinedAt,
      message: message ?? this.message,
    );
  }

  // Helper methods for business logic 

  // Returns true if the collaboration invitation is still pending response
  bool get isPending => status == CollaborationStatus.pending;

  // Returns true if the collaboration invitation has been accepted
  bool get isAccepted => status == CollaborationStatus.accepted;

  // Returns true if the collaboration invitation has been declined
  bool get isDeclined => status == CollaborationStatus.declined;

  // Returns true if the collaborator has edit permissions
  // Owners and editors can edit, viewers cannot
  bool get canEdit => role == CollaborationRole.owner || role == CollaborationRole.editor;
}
