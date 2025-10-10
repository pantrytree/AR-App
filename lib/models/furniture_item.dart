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