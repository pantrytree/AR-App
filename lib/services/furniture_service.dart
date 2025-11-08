import '../models/furniture_model.dart';

class FurnitureService {
  static final List<FurnitureItem> allFurniture = [
    // BEDROOM FURNITURE
    FurnitureItem(
      id: '1',
      name: 'Pink Queen Bed',
      roomCategory: 'bedroom',
      furnitureType: 'bed',
      style: 'modern',
      colors: ['Pink', 'White'],
      sizes: ['Queen', 'King'],
      material: 'Velvet',
      imageUrl: 'assets/furniture/beds/pink_bed.jpg',
      description: 'Luxurious pink queen bed with velvet upholstery and elegant wooden frame. Perfect for modern bedrooms.',
      arData: {'model': 'bed_pink_queen', 'scale': 1.0},
      rating: 4.5,
      reviewCount: 128,
      isFeatured: true,
    ),
    FurnitureItem(
      id: '2',
      name: 'Minimalist Wardrobe',
      roomCategory: 'bedroom',
      furnitureType: 'wardrobe',
      style: 'minimalist',
      colors: ['White', 'Grey'],
      sizes: ['Large', 'Extra Large'],
      material: 'Wood',
      imageUrl: 'assets/furniture/wardrobes/minimalist_wardrobe.jpg',
      description: 'Sleek minimalist wardrobe with ample storage space and smooth sliding doors.',
      arData: {'model': 'wardrobe_minimalist', 'scale': 1.2},
      rating: 4.3,
      reviewCount: 89,
      isFeatured: false,
    ),

    // LIVING ROOM FURNITURE
    FurnitureItem(
      id: '3',
      name: 'Grey Modern Sofa',
      roomCategory: 'living room',
      furnitureType: 'sofa',
      style: 'modern',
      colors: ['Grey', 'Black'],
      sizes: ['3-Seater', '2-Seater'],
      material: 'Fabric',
      imageUrl: 'assets/furniture/sofas/grey_sofa.jpg',
      description: 'Comfortable modern sofa with premium fabric and sturdy wooden frame.',
      arData: {'model': 'sofa_grey_modern', 'scale': 1.1},
      rating: 4.7,
      reviewCount: 156,
      isFeatured: true,
    ),
    FurnitureItem(
      id: '4',
      name: 'Silver Modern Lamp',
      roomCategory: 'living room',
      furnitureType: 'lamp',
      style: 'modern',
      colors: ['Silver', 'Black'],
      sizes: ['Standard'],
      material: 'Metal',
      imageUrl: 'assets/furniture/lamps/silver_lamp.jpg',
      description: 'Elegant silver lamp with dimmable LED lighting and adjustable arm.',
      arData: {'model': 'lamp_silver_modern', 'scale': 0.5},
      rating: 4.2,
      reviewCount: 64,
      isFeatured: true,
    ),

    // OFFICE FURNITURE
    FurnitureItem(
      id: '5',
      name: 'Wooden Office Desk',
      roomCategory: 'office',
      furnitureType: 'table',
      style: 'industrial',
      colors: ['Brown', 'Black'],
      sizes: ['Large', 'Medium'],
      material: 'Wood',
      imageUrl: 'assets/furniture/tables/wooden_desk.jpg',
      description: 'Sturdy wooden desk with metal legs, perfect for home office setup.',
      arData: {'model': 'desk_wooden_office', 'scale': 1.0},
      rating: 4.4,
      reviewCount: 92,
      isFeatured: false,
    ),
    FurnitureItem(
      id: '6',
      name: 'Ergonomic Office Chair',
      roomCategory: 'office',
      furnitureType: 'chair',
      style: 'modern',
      colors: ['Black', 'Grey'],
      sizes: ['Adjustable'],
      material: 'Mesh',
      imageUrl: 'assets/furniture/chairs/office_chair.jpg',
      description: 'Comfortable ergonomic chair with lumbar support and adjustable height.',
      arData: {'model': 'chair_ergonomic_office', 'scale': 0.9},
      rating: 4.6,
      reviewCount: 203,
      isFeatured: true,
    ),

    // DINING FURNITURE
    FurnitureItem(
      id: '7',
      name: 'Modern Dining Table',
      roomCategory: 'dining',
      furnitureType: 'table',
      style: 'modern',
      colors: ['White', 'Walnut'],
      sizes: ['6-Seater', '4-Seater'],
      material: 'Glass',
      imageUrl: 'assets/furniture/tables/dining_table.jpg',
      description: 'Elegant glass dining table with chrome legs, perfect for modern dining rooms.',
      arData: {'model': 'table_dining_modern', 'scale': 1.1},
      rating: 4.5,
      reviewCount: 78,
      isFeatured: false,
    ),
    FurnitureItem(
      id: '8',
      name: 'Upholstered Dining Chairs',
      roomCategory: 'dining',
      furnitureType: 'chair',
      style: 'traditional',
      colors: ['Beige', 'Brown'],
      sizes: ['Standard'],
      material: 'Fabric',
      imageUrl: 'assets/furniture/chairs/dining_chairs.jpg',
      description: 'Comfortable upholstered dining chairs with wooden legs.',
      arData: {'model': 'chair_dining_upholstered', 'scale': 0.8},
      rating: 4.3,
      reviewCount: 45,
      isFeatured: false,
    ),

  ];

  // Get furniture by room category
  static List<FurnitureItem> getByRoomCategory(String roomCategory) {
    if (roomCategory == 'all') return allFurniture;
    return allFurniture.where((item) => item.roomCategory == roomCategory).toList();
  }

  // Get furniture by type
  static List<FurnitureItem> getByFurnitureType(String furnitureType) {
    if (furnitureType == 'all') return allFurniture;
    return allFurniture.where((item) => item.furnitureType == furnitureType).toList();
  }

  // Get featured items
  static List<FurnitureItem> getFeaturedItems() {
    return allFurniture.where((item) => item.isFeatured).toList();
  }

  // Search furniture
  static List<FurnitureItem> searchFurniture(String query) {
    if (query.isEmpty) return allFurniture;
    return allFurniture.where((item) =>
    item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.description.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
