import 'package:flutter/material.dart';

class MainViewModel extends ChangeNotifier {
  // Navigation flags
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  // Current tab index
  int _currentIndex = 0;

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;
  int get currentIndex => _currentIndex;

  // Navigation methods
  void navigateToCamera() {
    _navigateToRoute = '/camera';
    _currentIndex = 0;
    notifyListeners();
  }

  void navigateToCatalogue() {
    _navigateToRoute = '/catalogue';
    _currentIndex = 1;
    notifyListeners();
  }

  void navigateToSettings() {
    _navigateToRoute = '/settings';
    _currentIndex = 2;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }
}