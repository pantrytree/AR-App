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

  factory Project.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Project(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      designIds: (data['designIds'] as List<dynamic>?)?.cast<String>() ?? [],
      collaboratorIds: (data['collaboratorIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] as bool? ?? false,
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'thumbnailUrl': thumbnailUrl,
      'designIds': designIds,
      'collaboratorIds': collaboratorIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'metadata': metadata,
      'tags': tags,
    };
  }

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