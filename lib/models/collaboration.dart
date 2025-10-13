// collaboration.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum CollaborationRole {
  owner,
  editor,
  viewer,
}

enum CollaborationStatus {
  pending,
  accepted,
  declined,
}

class Collaboration {
  final String id;
  final String projectId;
  final String inviterId;
  final String inviteeId;
  final CollaborationRole role;
  final CollaborationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? declinedAt;
  final String? message;

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

  factory Collaboration.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Collaboration(
      id: doc.id,
      projectId: data['projectId'] as String,
      inviterId: data['inviterId'] as String,
      inviteeId: data['inviteeId'] as String,
      role: CollaborationRole.values.firstWhere(
            (e) => e.name == data['role'],
        orElse: () => CollaborationRole.viewer,
      ),
      status: CollaborationStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => CollaborationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      declinedAt: data['declinedAt'] != null
          ? (data['declinedAt'] as Timestamp).toDate()
          : null,
      message: data['message'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'inviterId': inviterId,
      'inviteeId': inviteeId,
      'role': role.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'declinedAt': declinedAt != null ? Timestamp.fromDate(declinedAt!) : null,
      'message': message,
    };
  }

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

  // Helper methods
  bool get isPending => status == CollaborationStatus.pending;
  bool get isAccepted => status == CollaborationStatus.accepted;
  bool get isDeclined => status == CollaborationStatus.declined;
  bool get canEdit => role == CollaborationRole.owner || role == CollaborationRole.editor;
}