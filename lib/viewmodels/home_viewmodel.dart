import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // Navigation properties
  String? _navigateToRoute;
  dynamic _navigationArguments;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get selectedIndex => _selectedIndex;

  // Mock data - replace with actual data from your backend
  List<dynamic> get recentlyUsedItems => [
    {'id': '1', 'name': 'Pink Bed', 'imageUrl': null},
    {'id': '2', 'name': 'Silver Lamp', 'imageUrl': null},
    {'id': '3', 'name': 'Wooden Desk', 'imageUrl': null},
    {'id': '4', 'name': 'Grey Couch', 'imageUrl': null},
  ];

  List<dynamic> get userRooms => [
    {'id': '1', 'roomName': 'Living Room', 'roomType': 'living_room'},
    {'id': '2', 'roomName': 'Dining Room', 'roomType': 'dining_room'},
    {'id': '3', 'roomName': 'Office', 'roomType': 'office'},
    {'id': '4', 'roomName': 'Kitchen', 'roomType': 'kitchen'},
  ];

  dynamic get currentUser => {'displayName': 'Bulelwa'};

  // Bottom navigation method
  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();

    switch (index) {
      case 0: // Home (house icon) - stay on home page
        break;
      case 1: // Favorites (heart icon) - goes to Likes page
        _navigateToRoute = '/likes';
        notifyListeners();
        break;
      case 2: // Camera (camera icon) - goes to AR View page
        _navigateToRoute = '/ar_view';
        notifyListeners();
        break;
      case 3: // Shopping Bag (shopping bag icon) - goes to Cart page
        _navigateToRoute = '/cart';
        notifyListeners();
        break;
      case 4: // Profile (person icon) - goes to Edit Profile page
        _navigateToRoute = '/edit_profile';
        notifyListeners();
        break;
    }
  }

  // Existing navigation methods
  void onSearchTapped() {
    _navigateToRoute = '/search';
    notifyListeners();
  }

  void onFurnitureItemTapped(String id) {
    _navigateToRoute = '/catalogue_item';
    _navigationArguments = {'productId': id};
    notifyListeners();
  }

  void onRoomTapped(String id) {
    _navigateToRoute = '/catalogue';
    _navigationArguments = {'roomId': id};
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }

  // Existing methods
  void refreshHomePage() {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}