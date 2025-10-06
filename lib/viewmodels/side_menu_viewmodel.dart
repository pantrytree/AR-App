import 'package:flutter/material.dart';
import '/utils/text_components.dart';

class SideMenuViewModel extends ChangeNotifier {
  final String? _userName;

  SideMenuViewModel({String? userName}) : _userName = userName;

  // Menu items data
  final List<Map<String, dynamic>> _menuItems = [
    {"text": TextComponents.menuCatalogue, "icon": Icons.shopping_bag_outlined, "route": "/catalogue"},
    {"text": TextComponents.menuLikes, "icon": Icons.favorite_outline, "route": "/likes"},
    {"text": TextComponents.menuProjects, "icon": Icons.work_outline, "route": "/projects"},
    {"text": TextComponents.menuSettings, "icon": Icons.settings_outlined, "route": "/settings"},
    {"text": TextComponents.menuHelp, "icon": Icons.help_outline, "route": "/help"},
    {"text": TextComponents.menuForgotPassword, "icon": Icons.lock_reset, "route": "/forgot_password"},
    {"text": TextComponents.menuLogout, "icon": Icons.logout, "route": "/logout"},
  ];

  // Getters
  List<Map<String, dynamic>> get menuItems => _menuItems;
  String? get userName => _userName;

  // Navigation method
  void navigateToRoute(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer first
    Navigator.pushNamed(context, route);
  }
}