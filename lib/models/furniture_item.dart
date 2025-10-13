class FurnitureItem {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final Map<String, dynamic> dimensions; // {width, height, depth}
  final List<String> colors;
  final String? imageUrl;
  final String? modelUrl;
  final String? arModelUrl;
  final List<String> galleryImages;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  FurnitureItem({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.dimensions = const {},
    this.colors = const [],
    this.imageUrl,
    this.modelUrl,
    this.arModelUrl,
    this.galleryImages = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory FurnitureItem.fromJson(Map<String, dynamic> json) {
    return FurnitureItem(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'].toString(),
      dimensions: json['dimensions'] as Map<String, dynamic>? ?? {},
      colors: (json['colors'] as List?)?.cast<String>() ?? [],
      imageUrl: json['image_url'] as String?,
      modelUrl: json['model_url'] as String?,
      arModelUrl: json['ar_model_url'] as String?,
      galleryImages: (json['gallery_images'] as List?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'dimensions': dimensions,
      'colors': colors,
      'image_url': imageUrl,
      'model_url': modelUrl,
      'ar_model_url': arModelUrl,
      'gallery_images': galleryImages,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}