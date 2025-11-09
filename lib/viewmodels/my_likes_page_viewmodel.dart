import 'package:flutter/foundation.dart';


// handles:

//   - Loading liked items
//   - Filtering items by category
//   - Removing liked items
//   - Navigation placeholders for “Explore Products”

// NOTE FOR BACKEND TEAM:
//   • All “TODO” comments mark areas that should later connect to real APIs.
//   • Currently uses placeholder local data (no models or backend calls).

// Example API endpoints to integrate later:
//   - GET    /likes               → Fetch user liked items
//   - DELETE /likes/{id}          → Remove a liked item
//   - (Optional) POST /likes      → Add a liked item



class MyLikesViewModel extends ChangeNotifier {
  // Loading and error state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Categories for filtering
  final List<String> _categories = ['All', 'Furniture', 'Designs', 'Projects'];
  List<String> get categories => List.unmodifiable(_categories);

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  // Liked items (stored locally as placeholder maps)
  // Each map represents one liked item.
  final List<Map<String, dynamic>> _likedItems = [];
  List<Map<String, dynamic>> get likedItems => List.unmodifiable(_likedItems);

  // Updates the currently selected category.
  // Triggers a UI rebuild so the displayed items reflect this filter.
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Filters liked items based on the currently selected category.
  // Returns all items if the selected category is "All".
  //
  // TODO (Backend): Replace with backend-side filtering when supported.
  List<Map<String, dynamic>> getFilteredItems() {
    if (_selectedCategory == 'All') return _likedItems;
    return _likedItems
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  // Removes a liked item from the local list.
  //
  // Called when a user unlikes a product from their saved items.
  //
  // TODO (Backend): Replace this with a DELETE request to:
  //     DELETE /likes/{id}
  void removeLikedItem(String id) {
    _likedItems.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }

  // Placeholder function triggered when the "Explore Products" button is pressed.
  //
  // TODO (Backend/Navigation): Connect this to the real "Explore Products" page.
  void exploreProducts() {
    debugPrint('Navigate to explore products (placeholder)');
  }

  // Loads liked items.
  // Currently simulates an API call by using placeholder data
  // and a short delay to mimic a network request.
  //
  // TODO (Backend): Replace this with a GET request to:
  //     GET /likes
  //
  // Expected API response format:
  // [
  //   { "id": "1", "name": "Modern Chair", "category": "Furniture", "dimensions": "80x60x90 cm", "image": "..." },
  //   { "id": "2", "name": "Minimalist Sofa", "category": "Furniture", "dimensions": "200x90x100 cm", "image": "..." }
  // ]
  Future<void> loadLikedItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      // Placeholder liked items
      _likedItems.clear();
      _likedItems.addAll([
        {
          'id': '1',
          'name': 'Modern Chair',
          'dimensions': '80x60x90 cm',
          'category': 'Furniture',
          'image': null, // TODO: Replace with actual product image URL from backend
        },
        {
          'id': '2',
          'name': 'Minimalist Sofa',
          'dimensions': '200x90x100 cm',
          'category': 'Furniture',
          'image': null,
        },
        {
          'id': '3',
          'name': 'Living Room Concept',
          'dimensions': '',
          'category': 'Designs',
          'image': null,
        },
        {
          'id': '4',
          'name': 'Office Space Project',
          'dimensions': '',
          'category': 'Projects',
          'image': null,
        },
      ]);

      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load liked items.';
      debugPrint('MyLikesViewModel.loadLikedItems error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
