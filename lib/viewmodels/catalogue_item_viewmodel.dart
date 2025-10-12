import 'package:flutter/foundation.dart';
import '../models/furniture_item.dart';
import '../services/furniture_service.dart';

class CatalogueItemViewModel extends ChangeNotifier {
  final FurnitureService _service = FurnitureService();
  FurnitureItem? _selectedItem;
  bool _isLoading = false;
  String? _error;

  FurnitureItem? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItem(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedItem = _service.getItemById(itemId);
      if (_selectedItem == null) {
        _error = 'Item not found';
      }
    } catch (e) {
      _error = 'Failed to load item: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}