import 'package:flutter/foundation.dart';
import '../models/furniture_model.dart';

class LikesService with ChangeNotifier {
  final List<FurnitureItem> _likedItems = [];

  List<FurnitureItem> get likedItems => _likedItems;

  bool isLiked(String itemId) {
    return _likedItems.any((item) => item.id == itemId);
  }

  void addToLikes(FurnitureItem item) {
    if (!isLiked(item.id)) {
      _likedItems.add(item);
      notifyListeners();
    }
  }

  void removeFromLikes(String itemId) {
    _likedItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void toggleLike(FurnitureItem item) {
    if (isLiked(item.id)) {
      removeFromLikes(item.id);
    } else {
      addToLikes(item);
    }
  }

  List<FurnitureItem> getLikedItemsByCategory(String category) {
    if (category == 'All') {
      return _likedItems;
    }
    return _likedItems.where((item) => item.roomCategory.toLowerCase() == category.toLowerCase()).toList();
  }

  void clearAllLikes() {
    _likedItems.clear();
    notifyListeners();
  }
}