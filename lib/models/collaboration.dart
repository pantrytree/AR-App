import 'user.dart';
import 'user_room.dart';

class Collaboration {
  final String id;
  final String roomId;
  final UserRoom? room;
  final String designerId;
  final User? designer;
  final String clientId;
  final User? client;
  final String status;
  final String? message;
  final List<String> permissions;
  final DateTime? lastActivityAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collaboration({
    required this.id,
    required this.roomId,
    this.room,
    required this.designerId,
    this.designer,
    required this.clientId,
    this.client,
    required this.status,
    this.message,
    this.permissions = const ['view'],
    this.lastActivityAt,
    this.acceptedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collaboration.fromJson(Map<String, dynamic> json) {
    return Collaboration(
      id: json['id'].toString(),
      roomId: json['room_id'].toString(),
      room: json['room'] != null
          ? UserRoom.fromJson(json['room'] as Map<String, dynamic>)
          : null,
      designerId: json['designer_id'].toString(),
      designer: json['designer'] != null
          ? User.fromJson(json['designer'] as Map<String, dynamic>)
          : null,
      clientId: json['client_id'].toString(),
      client: json['client'] != null
          ? User.fromJson(json['client'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      message: json['message'] as String?,
      permissions: (json['permissions'] as List?)?.cast<String>() ?? ['view'],
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'room': room?.toJson(),
      'designer_id': designerId,
      'designer': designer?.toJson(),
      'client_id': clientId,
      'client': client?.toJson(),
      'status': status,
      'message': message,
      'permissions': permissions,
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isRejected => status == 'rejected';
  bool get canEdit => permissions.contains('edit');
  bool get canComment => permissions.contains('comment');
  bool get canView => permissions.contains('view');
}