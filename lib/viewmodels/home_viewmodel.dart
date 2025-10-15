import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  // Navigation properties
  String? _navigateToRoute;
  dynamic _navigationArguments;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  // Real data properties - will be populated by backend
  String? _userName;
  List<dynamic> _recentlyUsedItems = [];
  List<dynamic> _userRooms = [];

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get selectedIndex => _selectedIndex;

  // Backend data getters
  String? get userName => _userName;
  List<dynamic> get recentlyUsedItems => _recentlyUsedItems.isNotEmpty ? _recentlyUsedItems : _recentlyUsedItemsMock;
  List<dynamic> get userRooms => _userRooms.isNotEmpty ? _userRooms : _userRoomsMock;

  // Mock data - fallback until backend is implemented
  List<dynamic> get _recentlyUsedItemsMock => [
    {'id': '1', 'name': 'Pink Bed', 'imageUrl': null},
    {'id': '2', 'name': 'Silver Lamp', 'imageUrl': null},
    {'id': '3', 'name': 'Wooden Desk', 'imageUrl': null},
    {'id': '4', 'name': 'Grey Couch', 'imageUrl': null},
  ];

  List<dynamic> get _userRoomsMock => [
    {'id': '1', 'roomName': 'Living Room', 'roomType': 'living_room'},
    {'id': '2', 'roomName': 'Dining Room', 'roomType': 'dining_room'},
    {'id': '3', 'roomName': 'Office', 'roomType': 'office'},
    {'id': '4', 'roomName': 'Kitchen', 'roomType': 'kitchen'},
  ];

  dynamic get currentUser => {'displayName': _userName ?? 'Bulelwa'};

  // ======================
  // BACKEND INTEGRATION POINTS
  // ======================

  // TODO: Backend - Implement fetchUserName()
  // Description: Gets the current user's name from the users table
  // Expected: Returns String (user name)
  Future<String?> _fetchUserName() async {
    // Backend team to implement:
    // - Query users table for current user
    // - Return user's display name
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return 'Bulelwa'; // Mock response
  }

  // TODO: Backend - Implement fetchRecentlyUsedItems()
  // Description: Retrieves items from recently_used_items table
  // Expected: Returns List<Map> with item data
  Future<List<dynamic>> _fetchRecentlyUsedItems() async {
    // Backend team to implement:
    // - Query recently_used_items table for current user
    // - Return list of recently used furniture items
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return _recentlyUsedItemsMock; // Mock response
  }

  // TODO: Backend - Implement fetchRoomCategories()
  // Description: Loads data from room_categories table
  // Expected: Returns List<Map> with room categories
  Future<List<dynamic>> _fetchRoomCategories() async {
    // Backend team to implement:
    // - Query room_categories table
    // - Return list of available room categories
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return _userRoomsMock; // Mock response
  }

  // ======================
  // PUBLIC METHODS
  // ======================

  // Refresh home page data - calls all backend functions
  Future<void> refreshHomePage() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Backend team: These functions need implementation
      _userName = await _fetchUserName();
      _recentlyUsedItems = await _fetchRecentlyUsedItems();
      _userRooms = await _fetchRoomCategories();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Bottom navigation method
  // Bottom navigation method
  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();

    switch (index) {
      case 0: // Home
      // Already on home, do nothing
        break;
      case 1: // Favorites
        _navigateToRoute = '/likes';
        notifyListeners();
        break;
      case 2: // AR View (Camera)
        _navigateToRoute = '/camera_page'; // CHANGED: Navigate to camera page
        notifyListeners();
        break;
      case 3: // Shopping Bag - NOW GOES TO CATALOGUE
        _navigateToRoute = '/catalogue';
        notifyListeners();
        break;
      case 4: // Profile
        _navigateToRoute = '/edit_profile';
        notifyListeners();
        break;
    }
  }

  // Navigation methods
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

  void onAllRoomsTitleTapped() {
    _navigateToRoute = '/catalogue';
  }

  void onShoppingBagTapped() {
    _navigateToRoute = '/catalogue';
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}