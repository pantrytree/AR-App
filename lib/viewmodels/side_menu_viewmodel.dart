import 'dart:io';

import 'package:flutter/material.dart';
import 'package:Roomantics/services/auth_service.dart';
import 'package:Roomantics/models/user.dart' as models;
import 'package:Roomantics/services/cloudinary_service.dart';

class SideMenuViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  String? _navigateToRoute;
  dynamic _navigationArguments;
  models.User? _currentUser;
  bool _isLoading = false;

  SideMenuViewModel({String? userName}) {
    _fetchUserProfile();
  }

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;
  bool get isLoading => _isLoading;
  String get userNameDisplay => _currentUser?.displayName ?? 'User';
  String? get userEmail => _currentUser?.email;
  String? get photoUrl => _currentUser?.photoUrl;
  models.User? get currentUser => _currentUser;

  // Fetch user profile from AuthService
  Future<void> _fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUserModel();
      print('User profile loaded: ${_currentUser?.displayName}');
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forceRefreshProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUserModel();
      print('Side menu profile refreshed: ${_currentUser?.displayName}');
    } catch (e) {
      print('Error refreshing side menu profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture(String imagePath) async {
    try {
      print('Uploading profile picture...');

      final userId = _authService.currentUserId;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      final imageFile = File(imagePath);

      final imageUrl = await _cloudinaryService.uploadProfileImageUnsigned(
        imageFile,
        userId,
      );

      await _authService.updatePhotoURL(imageUrl);

      await _fetchUserProfile();

      print('Profile picture updated');
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> logoutUser() async {
    try {
      print('Logging out...');
      await _authService.signOut();

      _navigateToRoute = '/logout';
      notifyListeners();

      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Menu items configuration
  List<Map<String, dynamic>> get menuItems => [
    {
      'text': 'Home',
      'icon': Icons.home_outlined,
      'route': '/home',
    },
    {
      'text': 'Catalogue',
      'icon': Icons.shopping_bag_outlined,
      'route': '/catalogue',
    },
    {
      'text': 'My Likes',
      'icon': Icons.favorite_outline,
      'route': '/my-likes',
    },
    {
      'text': 'Roomie Lab',
      'icon': Icons.work_outline,
      'route': '/roomieLab',
    },
    {
      'text': 'Settings',
      'icon': Icons.settings_outlined,
      'route': '/settings',
    },
    {
      'text': 'Help & Support',
      'icon': Icons.help_outline,
      'route': '/help',
    },
  ];

  // Navigation methods
  void onMenuItemTapped(String route) {
    _navigateToRoute = route;
    _navigationArguments = null;
    notifyListeners();
  }

  void onEditProfileTapped() {
    _navigateToRoute = '/edit-profile';
    _navigationArguments = null;
    notifyListeners();
  }

  void onDrawerOpened() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      forceRefreshProfile();
    });
  }

  void onRoomieLabTapped(){
    _navigateToRoute = '/roomieLab';
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUserProfile() async {
    await _fetchUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }
}