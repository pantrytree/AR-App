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

class FurnitureItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String modelUrl;
  final String imageUrl;
  final List<String> tags;
  final bool isFavorite;
  final String dimensions;
  final double scale;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.modelUrl,
    required this.imageUrl,
    required this.tags,
    this.isFavorite = false,
    required this.dimensions,
    this.scale = 1.0,
  });

  // Creates a copy of FurnitureItem with updated favorite status
  //
  // @param isFavorite: New favorite status
  // @return: New FurnitureItem instance with updated favorite state
  //
  // USAGE: For toggling favorites without mutating original object


  FurnitureItem copyWith({
    bool? isFavorite,
  }) {
    return FurnitureItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      modelUrl: modelUrl,
      imageUrl: imageUrl,
      tags: tags,
      isFavorite: isFavorite ?? this.isFavorite,
      dimensions: dimensions,
      scale: scale,
    );
  }
}