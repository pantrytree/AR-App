// design.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Design {
  final String id;
  final String name;
  final String projectId;
  final String userId;
  final String? description;
  final String? thumbnailUrl;

  // Room context (merged from Room model)
  final String? roomType; // 'living_room', 'bedroom', 'kitchen', 'bathroom', etc.
  final Map<String, dynamic>? roomDimensions; // {width, length, height, unit}
  final String? floorPlanUrl;
  final String? referencePhotoUrl; // Photo of the actual room for reference

  final List<String> designObjectIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  Design({
    required this.id,
    required this.name,
    required this.projectId,
    required this.userId,
    this.description,
    this.thumbnailUrl,
    this.roomType,
    this.roomDimensions,
    this.floorPlanUrl,
    this.referencePhotoUrl,
    this.designObjectIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.tags = const [],
    this.metadata,
  });

  factory Design.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Design(
      id: doc.id,
      name: data['name'] as String,
      projectId: data['projectId'] as String,
      userId: data['userId'] as String,
      description: data['description'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      roomType: data['roomType'] as String?,
      roomDimensions: data['roomDimensions'] != null
          ? Map<String, dynamic>.from(data['roomDimensions'] as Map)
          : null,
      floorPlanUrl: data['floorPlanUrl'] as String?,
      referencePhotoUrl: data['referencePhotoUrl'] as String?,
      designObjectIds: (data['designObjectIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] as bool? ?? false,
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'projectId': projectId,
      'userId': userId,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'roomType': roomType,
      'roomDimensions': roomDimensions,
      'floorPlanUrl': floorPlanUrl,
      'referencePhotoUrl': referencePhotoUrl,
      'designObjectIds': designObjectIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'tags': tags,
      'metadata': metadata,
    };
  }

  Design copyWith({
    String? id,
    String? name,
    String? projectId,
    String? userId,
    String? description,
    String? thumbnailUrl,
    String? roomType,
    Map<String, dynamic>? roomDimensions,
    String? floorPlanUrl,
    String? referencePhotoUrl,
    List<String>? designObjectIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Design(
      id: id ?? this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      roomType: roomType ?? this.roomType,
      roomDimensions: roomDimensions ?? this.roomDimensions,
      floorPlanUrl: floorPlanUrl ?? this.floorPlanUrl,
      referencePhotoUrl: referencePhotoUrl ?? this.referencePhotoUrl,
      designObjectIds: designObjectIds ?? this.designObjectIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
}