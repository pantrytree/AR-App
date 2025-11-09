import 'dart:async';
import 'package:flutter/foundation.dart';
import '/services/favorites_service.dart';
import '/models/furniture_item.dart';

class MyLikesViewModel extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

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

  // Liked items
  final List<FurnitureItem> _likedItems = [];
  List<FurnitureItem> get likedItems => List.unmodifiable(_likedItems);

  // Stream subscription for real-time updates
  StreamSubscription<List<String>>? _favoritesSubscription;

  MyLikesViewModel() {
    _setupFavoritesStream();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  // Sets up real-time stream for favorites
  void _setupFavoritesStream() {
    _favoritesSubscription = _favoritesService.streamFavoriteIds().listen(
          (List<String> favoriteIds) {
        if (_likedItems.isNotEmpty) {
          _syncFavoritesWithStream(favoriteIds);
        }
      },
      onError: (error) {
        debugPrint('Favorites stream error: $error');
      },
    );
  }

  // Sync local items with real-time stream updates
  void _syncFavoritesWithStream(List<String> favoriteIds) {
    _likedItems.removeWhere((item) => !favoriteIds.contains(item.id));
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<FurnitureItem> getFilteredItems() {
    if (_selectedCategory == 'All') return _likedItems;

    return _likedItems
        .where((item) => _mapCategoryForFiltering(item.category) == _selectedCategory)
        .toList();
  }

  String _mapCategoryForFiltering(String backendCategory) {
    final categoryMap = {
      'chair': 'Furniture',
      'sofa': 'Furniture',
      'table': 'Furniture',
      'bed': 'Furniture',
      'cabinet': 'Furniture',
      'lamp': 'Furniture',
      'desk': 'Furniture',
      'design': 'Designs',
      'project': 'Projects',
    };

    return categoryMap[backendCategory.toLowerCase()] ?? 'Furniture';
  }

  // Remove item from favorites
  Future<void> removeLikedItem(String id) async {
    try {
      final removedItem = _likedItems.firstWhere((item) => item.id == id);
      _likedItems.removeWhere((item) => item.id == id);
      notifyListeners();

      // Remove from backend
      await _favoritesService.removeFromFavorites(id);

      debugPrint('Removed from favorites: $id');
    } catch (e) {
      // Revert on error
      await loadLikedItems();
      _errorMessage = 'Failed to remove item from favorites';
      debugPrint('Error removing favorite: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addToFavorite(String itemId) async {
    try {
      await _favoritesService.addToFavorites(itemId);
      debugPrint('Successfully added to favorites: $itemId');
    } catch (e) {
      debugPrint('Error adding to favorite: $e');
      rethrow;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String itemId) async {
    try {
      return await _favoritesService.toggleFavorite(itemId);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  // Check if item is favorited
  Future<bool> isItemFavorite(String itemId) async {
    try {
      return await _favoritesService.isFavorite(itemId);
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  // Load liked items from backend
  Future<void> loadLikedItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('Loading favorites...');

      final List<FurnitureItem> favorites = await _favoritesService.getFavorites();

      _likedItems.clear();
      _likedItems.addAll(favorites);

      _isLoading = false;
      _errorMessage = null;

      debugPrint('Loaded ${_likedItems.length} favorites');
    } catch (e) {
      _errorMessage = 'Failed to load favorites. Please try again.';
      debugPrint('Error loading favorites: $e');
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  // Refresh favorites
  Future<void> refreshLikedItems() async {
    await loadLikedItems();
  }

  // Get favorite count
  Future<int> getFavoriteCount() async {
    try {
      return await _favoritesService.getFavoriteCount();
    } catch (e) {
      debugPrint('Error getting favorite count: $e');
      return _likedItems.length;
    }
  }

  // Get favorites by category
  Future<List<FurnitureItem>> getFavoritesByCategory(String category) async {
    try {
      return await _favoritesService.getFavoritesByCategory(category);
    } catch (e) {
      debugPrint('Error getting favorites by category: $e');
      return [];
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      await _favoritesService.clearAllFavorites();
      _likedItems.clear();
      notifyListeners();
      debugPrint('Cleared all favorites');
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      rethrow;
    }
  }
}
