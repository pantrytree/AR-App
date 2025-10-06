import 'package:flutter/material.dart';
import '/utils/text_components.dart';

class HomeViewModel extends ChangeNotifier {
  int _selectedIndex = 0;

  // Getters
  int get selectedIndex => _selectedIndex;

  // Tab selection
  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Recently used items data
  final List<Map<String, String>> _recentlyUsedItems = [
    {"title": TextComponents.recentItemBeigeCouch, "id": "1"},
    {"title": TextComponents.recentItemPinkBed, "id": "2"},
    {"title": TextComponents.recentItemSilver, "id": "3"},
  ];

  // Room categories data
  final List<Map<String, String>> _roomCategories = [
    {"title": TextComponents.roomCategoryLiving, "id": "living"},
    {"title": TextComponents.roomCategoryBedroom, "id": "bedroom"},
    {"title": TextComponents.roomCategoryKitchen, "id": "kitchen"},
    {"title": TextComponents.roomCategoryOffice, "id": "office"},
  ];

  // Getters for data
  List<Map<String, String>> get recentlyUsedItems => _recentlyUsedItems;
  List<Map<String, String>> get roomCategories => _roomCategories;

  // Navigation methods
  void navigateToCatalogueItem(BuildContext context) {
    Navigator.pushNamed(context, '/catalogue_item');
  }

  void navigateToCatalogue(BuildContext context) {
    Navigator.pushNamed(context, '/catalogue');
  }
}