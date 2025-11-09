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

 // Creates a Design instance from a Firestore document snapshot
 // Handles type conversion and provides default values for missing fields
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
      // Convert room dimensions map with type safety
      roomDimensions: data['roomDimensions'] != null
          ? Map<String, dynamic>.from(data['roomDimensions'] as Map)
          : null,
      floorPlanUrl: data['floorPlanUrl'] as String?,
      referencePhotoUrl: data['referencePhotoUrl'] as String?,
      // Convert design object IDs with empty list fallback
      designObjectIds: (data['designObjectIds'] as List<dynamic>?)?.cast<String>() ?? [],
      // Convert Firestore Timestamps to DateTime objects
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] as bool? ?? false,
      // Convert tags with empty list fallback
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      // Convert metadata map with type safety
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
    );
  }

  // Converts the Design instance to a Map for Firestore storage
  // Handles DateTime to Timestamp conversion and maintains data structure
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
      // Convert DateTime to Firestore Timestamp for storage
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'tags': tags,
      'metadata': metadata,
    };
  }

  // Creates a new Design instance with updated fields
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
