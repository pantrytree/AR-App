import 'package:flutter/material.dart';

class CatalogueViewModel extends ChangeNotifier {
  // TODO: Backend team - Replace with actual data from API
  // PLACEHOLDER DATA - Remove when backend implements
  final List<Map<String, dynamic>> _placeholderItems = [
    {
      'id': '1',
      'name': 'Sample Furniture',
      'description': 'Description will come from backend',
      'category': 'Bedroom',
      'imageUrl': '',
      'price': 0.0,
      'dimensions': {'width': 0, 'height': 0, 'depth': 0, 'unit': 'cm'},
      'isFavorite': false,
    }
  ];

  // UI state
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // PUBLIC GETTERS
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => ['All', 'Bedroom', 'Living Room', 'Kitchen'];

  List<Map<String, dynamic>> get filteredItems {
    // TODO: Backend team - Implement proper filtering
    // This is placeholder logic
    return _placeholderItems;
  }

  // ACTIONS
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    // TODO: Backend team - Implement search API call
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    // TODO: Backend team - Implement category filtering API call
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Backend team - Replace with actual API call
      // await FurnitureService().getFurnitureItems();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // TODO: Backend team - Implement proper error handling
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CatalogueViewModel() {
    loadItems();
  }
}