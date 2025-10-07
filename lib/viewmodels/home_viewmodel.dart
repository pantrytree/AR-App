import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/furniture_service.dart';
import '/utils/text_components.dart';

class HomeViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final FurnitureService _furnitureService = FurnitureService();

  int _selectedIndex = 0;
  String _userName = "Guest"; // Default fallback
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

      // FIX: Convert Map<String, dynamic> to Map<String, String>
      _recentlyUsedItems = recentItems.map((item) =>
      {
        "title": item["title"]?.toString() ?? "Unknown Item",
        "id": item["id"]?.toString() ?? "0"
      }
      ).toList();

      _roomCategories = categories.map((category) =>
      {
        "title": category["title"]?.toString() ?? "Unknown Category",
        "id": category["id"]?.toString() ?? "0"
      }
      ).toList();

    } catch (e) {
      // Graceful failure - use fallback data
      print("Failed to load data: $e - Using fallback data");
      _userName = "Guest";
      _recentlyUsedItems = [
        {"title": TextComponents.recentItemBeigeCouch, "id": "1"},
        {"title": TextComponents.recentItemPinkBed, "id": "2"},
        {"title": TextComponents.recentItemSilver, "id": "3"},
      ];
      _roomCategories = [
        {"title": TextComponents.roomCategoryLiving, "id": "living"},
        {"title": TextComponents.roomCategoryBedroom, "id": "bedroom"},
        {"title": TextComponents.roomCategoryKitchen, "id": "kitchen"},
        {"title": TextComponents.roomCategoryOffice, "id": "office"},
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