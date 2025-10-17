import 'package:flutter/material.dart';

import 'home_viewmodel.dart';

class CatalogueViewModel extends ChangeNotifier {
  final HomeViewModel _homeViewModel = HomeViewModel.instance;  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // PUBLIC GETTERS
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => ['All', 'Bedroom', 'Living Room', 'Office', 'Dining'];

  // Since we're navigating to FurnitureCatalogPage, we don't need filtered items here
  List<Map<String, dynamic>> get filteredItems => [];

  // ACTIONS
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      // No API call needed since we're navigating to other pages
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onBottomNavigationTapped(int index) {
    _homeViewModel.onTabSelected(index);
  }

  CatalogueViewModel() {
    loadItems();
  }
}