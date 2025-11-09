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

  final double price;
  final bool isFavorite;

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
    this.price = 0.0,
    this.isFavorite = false,
  });

 // Returns the primary image URL for display
  String get imageUrl =>
      thumbnailUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : '');

  // Formats dimensions into a readable string for UI display
  String get dimensionString {
    if (dimensions.isEmpty) return '';
    final unit = dimensions['unit'] ?? '';
    return '${dimensions['width']}x${dimensions['height']}x${dimensions['depth']} $unit';
  }

  // Creates a FurnitureItem instance from a Firestore document snapshot
  // Handles type conversion and provides default values for missing fields
  factory FurnitureItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FurnitureItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrls: (data['imageUrls'] as List?)?.cast<String>() ?? const [],
      thumbnailUrl: data['thumbnailUrl'],
      // Convert dimensions map with empty map fallback
      dimensions: Map<String, dynamic>.from(data['dimensions'] ?? {}),
      colors: (data['colors'] as List?)?.cast<String>() ?? const [],
      modelUrl: data['modelUrl'],
      // Convert AR metadata map if present
      arMetadata: data['arMetadata'] != null
          ? Map<String, dynamic>.from(data['arMetadata'])
          : null,
      // Convert Firestore Timestamps with current time fallback
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: (data['tags'] as List?)?.cast<String>() ?? const [],
      // Convert numeric price to double with 0.0 fallback
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
    );
  }

  // Converts the FurnitureItem instance to a Map for Firestore storage
  // Handles DateTime to Timestamp conversion and maintains data structure
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
      // Convert DateTime to Firestore Timestamp for storage
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'price': price,
    };
  }

  // Creates a new FurnitureItem instance with updated fields
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
    double? price,
    bool? isFavorite,
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
      price: price ?? this.price,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Returns true if this furniture item has a 3D model for AR visualization
  bool get supportsAr => modelUrl != null && modelUrl!.isNotEmpty;
}
