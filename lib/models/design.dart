import 'package:cloud_firestore/cloud_firestore.dart';
import 'design_object.dart';

class Design {
  final String id;
  final String userId;
  final String projectId;
  final String name;
  final List<DesignObject> objects;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastViewed;

  Design({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.name,
    required this.objects,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastViewed,
  });

  // From JSON (API response)
  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Design',
      objects: (json['objects'] as List<dynamic>?)
          ?.map((e) => DesignObject.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      imageUrl: json['imageUrl'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      lastViewed: _parseDateTime(json['lastViewed'] ?? DateTime.now()), // FIXED: was referencing 'data'
    );
  }

  // From Firestore DocumentSnapshot
  factory Design.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Design(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      projectId: data['projectId'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled Design',
      objects: (data['objects'] as List<dynamic>?)
          ?.map((e) => DesignObject.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      imageUrl: data['imageUrl'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      lastViewed: _parseDateTime(data['lastViewed'] ?? DateTime.now()),
    );
  }

  // From Firestore Map
  factory Design.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return Design(
      id: id,
      userId: data['userId'] as String? ?? '',
      projectId: data['projectId'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled Design',
      objects: (data['objects'] as List<dynamic>?)
          ?.map((e) => DesignObject.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      imageUrl: data['imageUrl'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      lastViewed: _parseDateTime(data['lastViewed'] ?? DateTime.now()),
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'name': name,
      'objects': objects.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastViewed': lastViewed.toIso8601String(),
    };
  }

  // To Firestore (for Firestore writes)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'projectId': projectId,
      'name': name,
      'objects': objects.map((e) => e.toMap()).toList(),
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastViewed': Timestamp.fromDate(lastViewed),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now(); // Fallback
  }

  Design copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? name,
    List<DesignObject>? objects,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastViewed,
  }) {
    return Design(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      objects: objects ?? this.objects,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastViewed: lastViewed ?? this.lastViewed,
    );
  }

  @override
  String toString() => 'Design(id: $id, name: $name, objects: ${objects.length}, lastViewed: $lastViewed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Design &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}