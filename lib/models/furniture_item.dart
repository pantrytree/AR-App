// furniture_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FurnitureItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final Map<String, dynamic> dimensions; // {width, height, depth, unit}
  final List<String> colors;
  final String? modelUrl; // 3D model URL for AR
  final Map<String, dynamic>? arMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrls,
    this.thumbnailUrl,
    required this.dimensions,
    this.colors = const [],
    this.modelUrl,
    this.arMetadata,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  factory FurnitureItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FurnitureItem(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      imageUrls: (data['imageUrls'] as List<dynamic>).cast<String>(),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      dimensions: Map<String, dynamic>.from(data['dimensions'] as Map),
      colors: (data['colors'] as List<dynamic>?)?.cast<String>() ?? [],
      modelUrl: data['modelUrl'] as String?,
      arMetadata: data['arMetadata'] != null
          ? Map<String, dynamic>.from(data['arMetadata'] as Map)
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrls': imageUrls,
      'thumbnailUrl': thumbnailUrl,
      'dimensions': dimensions,
      'colors': colors,
      'modelUrl': modelUrl,
      'arMetadata': arMetadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
    };
  }

  FurnitureItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    List<String>? imageUrls,
    String? thumbnailUrl,
    Map<String, dynamic>? dimensions,
    List<String>? colors,
    String? modelUrl,
    Map<String, dynamic>? arMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return FurnitureItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      dimensions: dimensions ?? this.dimensions,
      colors: colors ?? this.colors,
      modelUrl: modelUrl ?? this.modelUrl,
      arMetadata: arMetadata ?? this.arMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  // Helper to check if this item supports AR
  bool get supportsAr => modelUrl != null && modelUrl!.isNotEmpty;
}
