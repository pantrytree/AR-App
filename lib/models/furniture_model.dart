class FurnitureItem {
  final String id;
  final String name;
  final String roomCategory; // 'living room', 'bedroom', 'office', 'kitchen', 'dining'
  final String furnitureType; // 'bed', 'sofa', 'table', 'chair', 'lamp', 'wardrobe'
  final String style; // 'modern', 'traditional', 'minimalist'
  final List<String> colors;
  final List<String> sizes;
  final String material; // 'wood', 'metal', 'fabric'
  final String imageUrl;
  final String description;
  final Map<String, dynamic> arData;
  final double rating;
  final int reviewCount;
  final bool isFeatured;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.roomCategory,
    required this.furnitureType,
    required this.style,
    required this.colors,
    required this.sizes,
    required this.material,
    required this.imageUrl,
    required this.description,
    required this.arData,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
  });

  // Helper method to check if item matches filters
  bool matchesFilters({
    String roomFilter = 'all',
    String typeFilter = 'all',
    String styleFilter = 'all',
    String searchQuery = '',
  }) {
    bool roomMatch = roomFilter == 'all' || roomCategory.toLowerCase() == roomFilter.toLowerCase();
    bool typeMatch = typeFilter == 'all' || furnitureType.toLowerCase() == typeFilter.toLowerCase();
    bool styleMatch = styleFilter == 'all' || style.toLowerCase() == styleFilter.toLowerCase();
    bool searchMatch = searchQuery.isEmpty ||
        name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        description.toLowerCase().contains(searchQuery.toLowerCase());

    return roomMatch && typeMatch && styleMatch && searchMatch;
  }
}