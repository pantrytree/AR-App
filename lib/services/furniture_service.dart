// // FurnitureService - Mock Data Service for Development
// //
// // PURPOSE: Provides furniture data during development phase
// //
// // CURRENT: Mock data with simulated API delays
// // FUTURE: Will be replaced with real backend API integration
// //
// // API ENDPOINTS TO IMPLEMENT:
// // - GET /api/furniture -> getAllFurniture()
// // - GET /api/furniture/{id} -> getItemById(id)
// // - GET /api/furniture?category={category} -> getItemsByCategory(category)
// // - GET /api/furniture/search?q={query} -> searchFurniture(query)
// // - GET /api/favorites -> getFavorites()
// //
// // DATA SOURCE: Currently uses hardcoded mock data with Picsum images
//
//
// // ignore_for_file: avoid_print
//
// import '../models/furniture_item.dart';
//
// class FurnitureService {
//   List<FurnitureItem> _cachedItems = [];
//
//   // Retrieves all furniture items
//   //
//   // CURRENT: Returns mock data with caching
//   // FUTURE: Will make API call to /api/furniture
//   //
//   // @return: List of FurnitureItem objects
//
//   List<FurnitureItem> getAllFurniture() {
//     if (_cachedItems.isNotEmpty) return _cachedItems;
//
//     print('🔄 Loading furniture items...');
//     // TO DO: Replace with API call to /api/furniture
//     _cachedItems = [
//       FurnitureItem(
//         id: '1',
//         name: 'Queen Bed',
//         description: 'Custom-made, handcrafted furniture designed to fit your unique style and space.',
//         price: 899.99,
//         category: 'Bedroom',
//         modelUrl: 'https://example.com/models/bed.usdz',
//         imageUrl: 'https://picsum.photos/200/100?random=1',
//         // Simple test image
//         tags: ['bed', 'bedroom', 'queen', 'sleep'],
//         dimensions: '80×80 cm',
//         scale: 1.0,
//       ),
//       FurnitureItem(
//         id: '2',
//         name: 'Bedside Table',
//         description: 'Modern bedside table with drawer storage',
//         price: 149.99,
//         category: 'Bedroom',
//         modelUrl: 'https://example.com/models/table.usdz',
//         imageUrl: 'https://picsum.photos/200/100?random=2',
//         // Simple test image
//         tags: ['table', 'bedside', 'bedroom', 'storage'],
//         dimensions: '30×60 cm',
//         scale: 1.0,
//       ),
//       FurnitureItem(
//         id: '3',
//         name: 'Sofa',
//         description: 'Comfortable 3-seater living room sofa',
//         price: 1299.99,
//         category: 'Living Room',
//         modelUrl: 'https://example.com/models/sofa.usdz',
//         imageUrl: 'https://picsum.photos/200/100?random=3',
//         // Simple test image
//         tags: ['sofa', 'living room', 'comfortable'],
//         dimensions: '200×90 cm',
//         scale: 1.0,
//       ),
//       FurnitureItem(
//         id: '4',
//         name: 'Coffee Table',
//         description: 'Glass top coffee table for living room',
//         price: 299.99,
//         category: 'Living Room',
//         modelUrl: 'https://example.com/models/coffee_table.usdz',
//         imageUrl: 'https://picsum.photos/200/100?random=4',
//         // Simple test image
//         tags: ['table', 'coffee', 'living room'],
//         dimensions: '120×60 cm',
//         scale: 1.0,
//       ),
//       FurnitureItem(
//         id: '5',
//         name: 'Dining Table',
//         description: '6-seater dining table for kitchen',
//         price: 799.99,
//         category: 'Kitchen',
//         modelUrl: 'https://example.com/models/dining_table.usdz',
//         imageUrl: 'https://picsum.photos/200/100?random=5',
//         // Simple test image
//         tags: ['table', 'dining', 'kitchen'],
//         dimensions: '180×90 cm',
//         scale: 1.0,
//       ),
//       FurnitureItem(
//         id: '6',
//         name: 'Kitchen Cabinet',
//         description: 'Modern kitchen storage cabinet',
//         price: 599.99,
//         category: 'Kitchen',
//         modelUrl: 'https://example.com/models/cabinet.usdz',
//         imageUrl: 'https://picsum.photos/200/100?random=6',
//         // Simple test image
//         tags: ['cabinet', 'kitchen', 'storage'],
//         dimensions: '120×200 cm',
//         scale: 1.0,
//       ),
//     ];
//
//     print('✅ Loaded ${_cachedItems.length} items');
//     for (var item in _cachedItems) {
//       print('   - ${item.name}: ${item.imageUrl}');
//     }
//
//     return _cachedItems;
//   }
//
//   // Finds furniture item by ID
//   //
//   // FUTURE: Will call /api/furniture/{id} endpoint
//   //
//   // @param id: Item identifier
//   // @return: FurnitureItem or null if not found
//   FurnitureItem? getItemById(String id) {
//     final items = getAllFurniture();
//     try {
//       return items.firstWhere((item) => item.id == id);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<List<FurnitureItem>> getFurnitureItems() async {
//     await Future.delayed(const Duration(seconds: 1));
//     return getAllFurniture();
//   }
//
//   Future<List<FurnitureItem>> getFavorites() async {
//     final items = await getFurnitureItems();
//     return items.where((item) => item.isFavorite).toList();
//   }
//
//   Future<List<FurnitureItem>> getItemsByCategory(String category) async {
//     final items = await getFurnitureItems();
//     if (category == 'All') return items;
//     return items.where((item) => item.category == category).toList();
//   }
//
//   Future<List<String>> getCategories() async {
//     final items = await getFurnitureItems();
//     final categories = items.map((item) => item.category).toSet().toList();
//     categories.insert(0, 'All');
//     return categories;
//   }
//
// }