import 'package:cloud_firestore/cloud_firestore.dart';

class FurnitureItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String roomType;
  final String? imageUrl;
  final List<String>? images;
  final String? dimensions;
  final String? color;
  final bool featured;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? arModelUrl;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.roomType,
    this.imageUrl,
    this.images,
    this.dimensions,
    this.color,
    this.featured = false,
    required this.createdAt,
    this.updatedAt,
    this.arModelUrl,
  });

  // From JSON (API response)
  factory FurnitureItem.fromJson(Map<String, dynamic> json) {
    return FurnitureItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      roomType: json['roomType'] as String,
      imageUrl: json['imageUrl'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dimensions: json['dimensions'] as String?,
      color: json['color'] as String?,
      featured: json['featured'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
      arModelUrl: json['arModelUrl'] as String?,
    );
  }

  // From Firestore DocumentSnapshot
  factory FurnitureItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FurnitureItem(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      roomType: data['roomType'] as String,
      imageUrl: data['imageUrl'] as String?,
      images: (data['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dimensions: data['dimensions'] as String?,
      color: data['color'] as String?,
      featured: data['featured'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      arModelUrl: data['arModelUrl'] as String?,
    );
  }

  // From Firestore Map
  factory FurnitureItem.fromFirestoreMap(Map<String, dynamic> data, String id) {
    return FurnitureItem(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      roomType: data['roomType'] as String,
      imageUrl: data['imageUrl'] as String?,
      images: (data['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dimensions: data['dimensions'] as String?,
      color: data['color'] as String?,
      featured: data['featured'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      arModelUrl: data['arModelUrl'] as String?,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'roomType': roomType,
      'imageUrl': imageUrl,
      'images': images,
      'dimensions': dimensions,
      'color': color,
      'featured': featured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'arModelUrl': arModelUrl,
    };
  }

  // To Firestore (for Firestore writes)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'roomType': roomType,
      'imageUrl': imageUrl,
      'images': images ?? [],
      'dimensions': dimensions,
      'color': color,
      'featured': featured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'arModelUrl': arModelUrl,
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

  FurnitureItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? roomType,
    String? imageUrl,
    List<String>? images,
    String? dimensions,
    String? color,
    bool? featured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? arModelUrl,
  }) {
    return FurnitureItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      roomType: roomType ?? this.roomType,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      dimensions: dimensions ?? this.dimensions,
      color: color ?? this.color,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      arModelUrl: arModelUrl ?? this.arModelUrl,
    );
  }

  @override
  String toString() => 'FurnitureItem(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FurnitureItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}