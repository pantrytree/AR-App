import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/furniture_service.dart';

class HomeViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final FurnitureService _furnitureService = FurnitureService();

  int _selectedIndex = 0;
  String _userName = "Guest"; // Placeholder data
  bool _isLoading = true;
  List<Map<String, String>> _recentlyUsedItems = [];
  List<Map<String, String>> _roomCategories = [];

  // Getters
  int get selectedIndex => _selectedIndex;
  String get userName => _userName;
  bool get isLoading => _isLoading;
  List<Map<String, String>> get recentlyUsedItems => _recentlyUsedItems;
  List<Map<String, String>> get roomCategories => _roomCategories;

  // Load all data with graceful failure
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to get real data from services
      final userName = await _userService.getCurrentUserName();
      final recentItems = await _furnitureService.getRecentlyUsedItems();
      final categories = await _furnitureService.getRoomCategories();

      _userName = userName;
      _recentlyUsedItems = recentItems.cast<Map<String, String>>();
      _roomCategories = categories.cast<Map<String, String>>();

    } catch (e) {
      // 'breaking gracefully' - use fallback data
      print("Failed to load data: $e - Using fallback data");
      _userName = "Guest";
      _recentlyUsedItems = [
        {"title": "Beige Couch", "id": "1"}, // Placeholder data
        {"title": "Pink Bed", "id": "2"}, // Placeholder data
        {"title": "Silver Lamp", "id": "3"}, // Placeholder data
      ];
      _roomCategories = [
        {"title": "Living Room", "id": "living"}, // Placeholder data
        {"title": "Bedroom", "id": "bedroom"}, // Placeholder data
        {"title": "Kitchen", "id": "kitchen"}, // Placeholder data
        {"title": "Office", "id": "office"}, // Placeholder data
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tab selection
  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Navigation methods
  void navigateToCatalogueItem(BuildContext context) {
    Navigator.pushNamed(context, '/catalogue_item');
  }

  void navigateToCatalogue(BuildContext context) {
    Navigator.pushNamed(context, '/catalogue');
  }
}