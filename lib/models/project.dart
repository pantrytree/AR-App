import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String userId;
  final String name;
  final String roomType;
  final String description;
  final List<String> items;
  final List<String> collaborators;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final bool isPublic;

  // New fields for likes functionality
  final bool isLiked;
  final int likeCount;
  final List<String> likedBy;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    required this.roomType,
    required this.description,
    required this.items,
    required this.collaborators,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.isPublic = false,

    // Initialize new fields
    this.isLiked = false,
    this.likeCount = 0,
    this.likedBy = const [],
  });

  // From JSON (API response)
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      roomType: json['roomType'] as String,
      description: json['description'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      collaborators: (json['collaborators'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,

      // New fields
      isLiked: json['isLiked'] as bool? ?? false,
      likeCount: json['likeCount'] as int? ?? 0,
      likedBy: (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  // From Firestore DocumentSnapshot
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      roomType: data['roomType'] as String,
      description: data['description'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      collaborators: (data['collaborators'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      isPublic: data['isPublic'] as bool? ?? false,

      // New fields
      isLiked: data['isLiked'] as bool? ?? false,
      likeCount: data['likeCount'] as int? ?? 0,
      likedBy: (data['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  // From Firestore Map
  factory Project.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return Project(
      id: id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      roomType: data['roomType'] as String,
      description: data['description'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      collaborators: (data['collaborators'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] as String?,
      isPublic: data['isPublic'] as bool? ?? false,

      // New fields
      isLiked: data['isLiked'] as bool? ?? false,
      likeCount: data['likeCount'] as int? ?? 0,
      likedBy: (data['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'roomType': roomType,
      'description': description,
      'items': items,
      'collaborators': collaborators,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'isPublic': isPublic,

      // New fields
      'isLiked': isLiked,
      'likeCount': likeCount,
      'likedBy': likedBy,
    };
  }

  // To Firestore (for Firestore writes)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'roomType': roomType,
      'description': description,
      'items': items,
      'collaborators': collaborators,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrl': imageUrl,
      'isPublic': isPublic,

      // New fields
      'isLiked': isLiked,
      'likeCount': likeCount,
      'likedBy': likedBy,
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

  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? roomType,
    String? description,
    List<String>? items,
    List<String>? collaborators,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    bool? isPublic,
    bool? isLiked,
    int? likeCount,
    List<String>? likedBy,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      roomType: roomType ?? this.roomType,
      description: description ?? this.description,
      items: items ?? this.items,
      collaborators: collaborators ?? this.collaborators,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name, items: ${items.length}, likes: $likeCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Project &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}