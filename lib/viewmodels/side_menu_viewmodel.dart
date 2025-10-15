import 'package:flutter/material.dart';

class SideMenuViewModel extends ChangeNotifier {
  String? _userName;
  String? _navigateToRoute;
  dynamic _navigationArguments;

  SideMenuViewModel({String? userName}) {
    _userName = userName;
    _fetchUserProfile(); // Load user data on initialization
  }

  // ======================
  // BACKEND INTEGRATION POINTS
  // ======================

  // TODO: Backend - Implement fetchUserProfile()
  // Description: Pulls user data (name, email, profile picture) from users table
  // Expected: Returns user profile data including name, email, profile picture URL
  Future<void> _fetchUserProfile() async {
    // Backend team to implement:
    // - Query users table for current user
    // - Return user data including display name, email, profile picture
    // - Update _userName with actual data from database

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

    // Mock implementation - replace with actual backend call
    if (_userName == null) {
      // Backend team: Replace this with actual user data fetch
      _userName = 'Bulelwa'; // This should come from users table
    }

    notifyListeners();
  }

  // TODO: Backend - Implement updateProfilePicture()
  // Description: Updates profile picture field in users table
  // Expected: Returns success status and new picture URL
  Future<void> updateProfilePicture(String imagePath) async {
    // Backend team to implement:
    // - Upload image to storage
    // - Update profile_picture field in users table
    // - Return new image URL

    debugPrint("Updating profile picture - BACKEND NEEDED");
    // Backend team: Implement image upload and database update

    notifyListeners();
  }

  // TODO: Backend - Implement logoutUser()
  // Description: Logs out the current user and clears session
  // Expected: Returns success status
  Future<void> logoutUser() async {
    // Backend team to implement:
    // - Clear authentication tokens/session
    // - Navigate to login page
    // - Clear any user-specific cached data

    debugPrint("Logging out user - BACKEND NEEDED");

    // After backend logout, navigate to login
    _navigateToRoute = '/login';
    notifyListeners();
  }

  // ======================
  //PUBLIC METHODS & GETTERS
  // ======================

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;

  String get userNameDisplay => _userName ?? 'User';

  // Menu items configuration
  List<Map<String, dynamic>> get menuItems => [
    {
      'text': 'Home',
      'icon': Icons.home,
      'route': '/home',
    },
    {
      'text': 'Catalogue',
      'icon': Icons.shopping_bag,
      'route': '/catalogue',
    },
    {
      'text': 'My Likes',
      'icon': Icons.favorite,
      'route': '/likes',
    },
    {
      'text': 'My Projects',
      'icon': Icons.work,
      'route': '/projects',
    },
    {
      'text': 'Settings',
      'icon': Icons.settings,
      'route': '/settings',
    },
    {
      'text': 'Help & Support',
      'icon': Icons.help,
      'route': '/help',
    },
    {
      'text': 'Forgot Password',
      'icon': Icons.lock_reset,
      'route': '/forgot_password',
    },
  ];

  // Navigation methods
  void onMenuItemTapped(String route) {
    _navigateToRoute = route;
    _navigationArguments = null;
    notifyListeners();
  }

  void onEditProfileTapped() {
    _navigateToRoute = '/edit_profile';
    _navigationArguments = {'editMode': true};
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }

  // Update user name (for when backend provides real data)
  void updateUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}