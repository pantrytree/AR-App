import 'package:flutter/foundation.dart';

class MyLikesViewModel extends ChangeNotifier {

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;


  final List<String> categories = ['All', 'Chair', 'Sofa', 'Bed'];


  final List<Map<String, dynamic>> _likedItems = [];

  List<Map<String, dynamic>> get likedItems => _likedItems;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addLikedItem(Map<String, dynamic> item) {
    if (!_likedItems.any((existingItem) => existingItem['id'] == item['id'])) {
      _likedItems.add(item);
      notifyListeners();
    }
  }

  void removeLikedItem(int itemId) {
    _likedItems.removeWhere((item) => item['id'] == itemId);
    notifyListeners();
  }

  List<Map<String, dynamic>> getFilteredItems() {
    if (_selectedCategory == 'All') {
      return _likedItems;
    }
    return _likedItems.where((item) => item['category'] == _selectedCategory).toList();
  }

  Future<void> loadLikedItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load liked items. Please try again.';
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }
}