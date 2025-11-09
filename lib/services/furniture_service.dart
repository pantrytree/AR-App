import '../models/furniture_item.dart';

class FurnitureService {
  List<FurnitureItem> _cachedItems = [];

  // Retrieve all mock furniture items
  List<FurnitureItem> getAllFurniture() {
    if (_cachedItems.isNotEmpty) return _cachedItems;

    print('Loading furniture items...');

    final now = DateTime.now();

    //mock furniture data representing furniture catlogue
    _cachedItems = [
      FurnitureItem(
        id: '1',
        name: 'Queen Bed',
        description:
        'Custom-made, handcrafted queen-size bed designed to fit your unique style and space.',
        category: 'Bedroom',
        imageUrls: ['https://picsum.photos/200/100?random=1'],
        dimensions: {
          'width': 200,
          'height': 80,
          'depth': 180,
          'unit': 'cm',
        },
        tags: ['bed', 'bedroom', 'queen', 'sleep'],
        price: 899.99,
        createdAt: now,
        updatedAt: now,
      ),
      FurnitureItem(
        id: '2',
        name: 'Bedside Table',
        description: 'Modern bedside table with drawer storage.',
        category: 'Bedroom',
        imageUrls: ['https://picsum.photos/200/100?random=2'],
        dimensions: {
          'width': 40,
          'height': 60,
          'depth': 35,
          'unit': 'cm',
        },
        tags: ['table', 'bedroom', 'storage'],
        price: 149.99,
        createdAt: now,
        updatedAt: now,
      ),
      FurnitureItem(
        id: '3',
        name: 'Sofa',
        description: 'Comfortable 3-seater living room sofa with plush cushions.',
        category: 'Living Room',
        imageUrls: ['https://picsum.photos/200/100?random=3'],
        dimensions: {
          'width': 200,
          'height': 90,
          'depth': 80,
          'unit': 'cm',
        },
        tags: ['sofa', 'living room', 'comfortable'],
        price: 1299.99,
        createdAt: now,
        updatedAt: now,
      ),
      FurnitureItem(
        id: '4',
        name: 'Coffee Table',
        description: 'Glass-top coffee table with a minimalistic wooden frame.',
        category: 'Living Room',
        imageUrls: ['https://picsum.photos/200/100?random=4'],
        dimensions: {
          'width': 120,
          'height': 45,
          'depth': 60,
          'unit': 'cm',
        },
        tags: ['table', 'living room', 'coffee'],
        price: 299.99,
        createdAt: now,
        updatedAt: now,
      ),
      FurnitureItem(
        id: '5',
        name: 'Dining Table',
        description: 'Elegant 6-seater wooden dining table for your kitchen.',
        category: 'Kitchen',
        imageUrls: ['https://picsum.photos/200/100?random=5'],
        dimensions: {
          'width': 180,
          'height': 75,
          'depth': 90,
          'unit': 'cm',
        },
        tags: ['table', 'dining', 'kitchen'],
        price: 799.99,
        createdAt: now,
        updatedAt: now,
      ),
      FurnitureItem(
        id: '6',
        name: 'Kitchen Cabinet',
        description: 'Modern kitchen storage cabinet with multiple compartments.',
        category: 'Kitchen',
        imageUrls: ['https://picsum.photos/200/100?random=6'],
        dimensions: {
          'width': 120,
          'height': 200,
          'depth': 40,
          'unit': 'cm',
        },
        tags: ['cabinet', 'kitchen', 'storage'],
        price: 599.99,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    print('Loaded ${_cachedItems.length} items');
    return _cachedItems;
  }

  // Get item by ID
  FurnitureItem? getItemById(String id) {
    return getAllFurniture().firstWhere(
          (item) => item.id == id,
      orElse: () => _cachedItems.first,
    );
  }

  // Asynchronously retrieves all furniture items with simulated network delay
  Future<List<FurnitureItem>> getFurnitureItems() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return getAllFurniture();
  }

  // Returns furniture items marked as favorites by the user
  Future<List<FurnitureItem>> getFavorites() async {
    final items = await getFurnitureItems();
    return items.where((item) => item.isFavorite).toList();
  }

  // Filters furniture items by category
  // Returns all items if category is 'All', otherwise filters by specific category
  Future<List<FurnitureItem>> getItemsByCategory(String category) async {
    final items = await getFurnitureItems();
    if (category == 'All') return items;
    return items.where((item) => item.category == category).toList();
  }

  // Retrieves all unique furniture categories from the catalog
  // Always includes 'All' as the first option for comprehensive filtering
  Future<List<String>> getCategories() async {
    final items = await getFurnitureItems();
    final categories = items.map((item) => item.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }
}
