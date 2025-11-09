// project.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String? thumbnailUrl;
  final List<String> designIds;
  final List<String> collaboratorIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final Map<String, dynamic>? metadata;
  final List<String> tags;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.thumbnailUrl,
    this.designIds = const [],
    this.collaboratorIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.metadata,
    this.tags = const [],
  });

  // Creates a Project instance from a Firestore document snapshot
  // Handles type conversion and provides default values for missing fields
  factory Project.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Project(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      // Convert design IDs list with empty list fallback
      designIds: (data['designIds'] as List<dynamic>?)?.cast<String>() ?? [],
      // Convert collaborator IDs list with empty list fallback
      collaboratorIds: (data['collaboratorIds'] as List<dynamic>?)?.cast<String>() ?? [],
      // Convert Firestore Timestamps to DateTime objects
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] as bool? ?? false,
      // Convert metadata map if present
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
      // Convert tags list with empty list fallback
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Converts the Project instance to a Map for Firestore storage
  // Handles DateTime to Timestamp conversion and maintains data structure
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'thumbnailUrl': thumbnailUrl,
      'designIds': designIds,
      'collaboratorIds': collaboratorIds,
      // Convert DateTime to Firestore Timestamp for storage
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'metadata': metadata,
      'tags': tags,
    };
  }

  // Creates a new Project instance with updated fields
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? thumbnailUrl,
    List<String>? designIds,
    List<String>? collaboratorIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      designIds: designIds ?? this.designIds,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }
}
