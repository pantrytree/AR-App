import 'package:flutter/material.dart';

class SideMenuViewModel extends ChangeNotifier {
  final String? userName;

  String? _navigateToRoute;
  dynamic _navigationArguments;

  SideMenuViewModel({this.userName});

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;

  String get userNameDisplay => userName ?? 'User';

  // Menu items configuration
  List<Map<String, dynamic>> get menuItems => [
    {
      'text': 'Home',
      'icon': Icons.home,
      'route': '/home',
    },
    {
      'text': 'My Rooms',
      'icon': Icons.room,
      'route': '/rooms',
    },
    {
      'text': 'Furniture Catalog',
      'icon': Icons.chair,
      'route': '/catalog',
    },
    {
      'text': 'Favorites',
      'icon': Icons.favorite,
      'route': '/favorites',
    },
    {
      'text': 'Shopping Cart',
      'icon': Icons.shopping_cart,
      'route': '/cart',
    },
    {
      'text': 'Order History',
      'icon': Icons.history,
      'route': '/orders',
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
  ];

  // Navigation methods
  void onMenuItemTapped(String route) {
    _navigateToRoute = route;
    _navigationArguments = null;
    notifyListeners();
  }

  void onEditProfileTapped() {
    _navigateToRoute = '/profile';
    _navigationArguments = {'editMode': true};
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}