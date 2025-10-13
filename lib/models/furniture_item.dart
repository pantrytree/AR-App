// furniture_item.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FurnitureItem {
//   final String id;
//   final String name;
//   final String description;
//   final String category;
//   final List<String> imageUrls;
//   final String? thumbnailUrl;
//   final Map<String, dynamic> dimensions; // {width, height, depth, unit}
//   final List<String> colors;
//   final String? modelUrl; // 3D model URL for AR
//   final Map<String, dynamic>? arMetadata;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final List<String> tags;
//
//   FurnitureItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.category,
//     required this.imageUrls,
//     this.thumbnailUrl,
//     required this.dimensions,
//     this.colors = const [],
//     this.modelUrl,
//     this.arMetadata,
//     required this.createdAt,
//     required this.updatedAt,
//     this.tags = const [],
//   });
//
//   factory FurnitureItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
//     final data = doc.data()!;
//     return FurnitureItem(
//       id: doc.id,
//       name: data['name'] as String,
//       description: data['description'] as String,
//       category: data['category'] as String,
//       imageUrls: (data['imageUrls'] as List<dynamic>).cast<String>(),
//       thumbnailUrl: data['thumbnailUrl'] as String?,
//       dimensions: Map<String, dynamic>.from(data['dimensions'] as Map),
//       colors: (data['colors'] as List<dynamic>?)?.cast<String>() ?? [],
//       modelUrl: data['modelUrl'] as String?,
//       arMetadata: data['arMetadata'] != null
//           ? Map<String, dynamic>.from(data['arMetadata'] as Map)
//           : null,
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//       updatedAt: (data['updatedAt'] as Timestamp).toDate(),
//       tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
//     );
//   }
//
//   Map<String, dynamic> toFirestore() {
//     return {
//       'name': name,
//       'description': description,
//       'category': category,
//       'imageUrls': imageUrls,
//       'thumbnailUrl': thumbnailUrl,
//       'dimensions': dimensions,
//       'colors': colors,
//       'modelUrl': modelUrl,
//       'arMetadata': arMetadata,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': Timestamp.fromDate(updatedAt),
//       'tags': tags,
//     };
//   }
//
//   FurnitureItem copyWith({
//     String? id,
//     String? name,
//     String? description,
//     String? category,
//     List<String>? imageUrls,
//     String? thumbnailUrl,
//     Map<String, dynamic>? dimensions,
//     List<String>? colors,
//     String? modelUrl,
//     Map<String, dynamic>? arMetadata,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     List<String>? tags,
//   }) {
//     return FurnitureItem(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       description: description ?? this.description,
//       category: category ?? this.category,
//       imageUrls: imageUrls ?? this.imageUrls,
//       thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
//       dimensions: dimensions ?? this.dimensions,
//       colors: colors ?? this.colors,
//       modelUrl: modelUrl ?? this.modelUrl,
//       arMetadata: arMetadata ?? this.arMetadata,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       tags: tags ?? this.tags,
//     );
//   }
//
//   // Helper to check if this item supports AR
//   bool get supportsAr => modelUrl != null && modelUrl!.isNotEmpty;
// }

// FurnitureItem Data Model
//
// PURPOSE: Represents a furniture product in the Roomanties catalog
//
// API DATA MAPPING (Future Integration):
// - id: Unique identifier from backend database
// - name: Product display name
// - description: Product details and features
// - price: Retail price in local currency
// - category: Room classification (Bedroom, Living Room, Kitchen)
// - modelUrl: 3D model file URL for AR placement
// - imageUrl: Product image URL from CDN
// - tags: Searchable keywords and attributes
// - dimensions: Physical size information
// - scale: AR placement scale factor
//
// USAGE: Used across Catalogue, AR Camera, and Favorites features

// class FurnitureItem {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final String category;
//   final String modelUrl;
//   final String imageUrl;
//   final List<String> tags;
//   final bool isFavorite;
//   final String dimensions;
//   final double scale;
//
//   FurnitureItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.category,
//     required this.modelUrl,
//     required this.imageUrl,
//     required this.tags,
//     this.isFavorite = false,
//     required this.dimensions,
//     this.scale = 1.0,
//   });
//
//   // Creates a copy of FurnitureItem with updated favorite status
//   //
//   // @param isFavorite: New favorite status
//   // @return: New FurnitureItem instance with updated favorite state
//   //
//   // USAGE: For toggling favorites without mutating original object
//
//
//   FurnitureItem copyWith({
//     bool? isFavorite,
//   }) {
//     return FurnitureItem(
//       id: id,
//       name: name,
//       description: description,
//       price: price,
//       category: category,
//       modelUrl: modelUrl,
//       imageUrl: imageUrl,
//       tags: tags,
//       isFavorite: isFavorite ?? this.isFavorite,
//       dimensions: dimensions,
//       scale: scale,
//     );
//   }
// }
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

  // 🔹 Backward-compatibility fields
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

  // ✅ Primary image for older code
  String get imageUrl =>
      thumbnailUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : '');

  // ✅ Friendly dimensions string for display
  String get dimensionString {
    if (dimensions.isEmpty) return '';
    final unit = dimensions['unit'] ?? '';
    return '${dimensions['width']}x${dimensions['height']}x${dimensions['depth']} $unit';
  }

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
      dimensions: Map<String, dynamic>.from(data['dimensions'] ?? {}),
      colors: (data['colors'] as List?)?.cast<String>() ?? const [],
      modelUrl: data['modelUrl'],
      arMetadata: data['arMetadata'] != null
          ? Map<String, dynamic>.from(data['arMetadata'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: (data['tags'] as List?)?.cast<String>() ?? const [],
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
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
      'price': price,
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

  bool get supportsAr => modelUrl != null && modelUrl!.isNotEmpty;
}
