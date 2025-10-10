import 'package:flutter/material.dart';
import '../models/furniture_item.dart';
import '../services/furniture_service.dart';

/// CatalogueViewModel
/// - Holds product list (mocked via FurnitureService)
/// - Provides search & category filtering for the catalogue page.
class CatalogueViewModel extends ChangeNotifier {
  final FurnitureService _service = FurnitureService();

  // UI state
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  CatalogueViewModel() {
    _load();
  }

  // PUBLIC GETTERS
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  /// categories used in wireframe + "All"
  List<String> get categories => ['All', 'Bedroom', 'Living Room', 'Kitchen'];

  /// All items (from service)
  List<FurnitureItem> get allItems => _service.getAllFurniture();

  /// Filtered items based on search + category
  List<FurnitureItem> get filteredItems {
    List<FurnitureItem> filtered = allItems;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((i) => i.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  /// A banner image URL to use in header — default to first product image if available
  String? get headerImageUrl {
    final items = filteredItems;
    if (items.isNotEmpty) return items.first.imageUrl;
    final all = allItems;
    if (all.isNotEmpty) return all.first.imageUrl;
    return null;
  }

  // ACTIONS
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    // simulate short load
    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }
}

