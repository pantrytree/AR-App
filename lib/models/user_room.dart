class UserRoom {
  final String id;
  final String userId;
  final String roomName;
  final String roomType;
  final Map<String, dynamic> dimensions; // {width, length, height}
  final String? floorPlanImage;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserRoom({
    required this.id,
    required this.userId,
    required this.roomName,
    required this.roomType,
    this.dimensions = const {},
    this.floorPlanImage,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRoom.fromJson(Map<String, dynamic> json) {
    return UserRoom(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      roomName: json['room_name'] as String,
      roomType: json['room_type'] as String,
      dimensions: json['dimensions'] as Map<String, dynamic>? ?? {},
      floorPlanImage: json['floor_plan_image'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_name': roomName,
      'room_type': roomType,
      'dimensions': dimensions,
      'floor_plan_image': floorPlanImage,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}