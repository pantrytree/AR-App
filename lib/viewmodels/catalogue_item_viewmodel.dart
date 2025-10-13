import 'package:flutter/material.dart';
import '/utils/text_components.dart';

class CatalogueItemViewModel extends ChangeNotifier {
  final String? productId;

  CatalogueItemViewModel({this.productId}) {
    _loadProductData();
  }

  // Product data
  String _productTitle = TextComponents.productQueenBedTitle;
  String _productDimensions = TextComponents.productQueenBedDimensions;
  String _productDescription = TextComponents.productQueenBedDescription;
  bool _isFavorite = false;

  // Navigation flags
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  // Related items data
  final List<Map<String, String>> _relatedItems = [
    {"title": TextComponents.productBedsideTableTitle, "dimensions": TextComponents.productBedsideTableDimensions, "id": "1"},
    {"title": TextComponents.productWardrobeTitle, "dimensions": TextComponents.productWardrobeDimensions, "id": "2"},
    {"title": TextComponents.productDresserTitle, "dimensions": TextComponents.productDresserDimensions, "id": "3"},
  ];

  // Getters
  String get productTitle => _productTitle;
  String get productDimensions => _productDimensions;
  String get productDescription => _productDescription;
  bool get isFavorite => _isFavorite;
  List<Map<String, String>> get relatedItems => _relatedItems;
  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;

  // Load product data
  void _loadProductData() {
    debugPrint("Loading product data for ID: $productId");
    // TODO: Backend - Implement product data loading
  }

  // Add to cart functionality
  void addToCart() {
    debugPrint("Adding $productTitle to cart");
    // TODO: Backend - Implement CartService.addToCart()
  }

  // Toggle favorite status
  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
    debugPrint("${_isFavorite ? 'Added' : 'Removed'} $productTitle from favorites");
    // TODO: Backend - Implement FavoritesService.toggleFavorite()
  }

  // Navigate to related item using flags
  void navigateToRelatedItem(String relatedProductId) {
    _navigateToRoute = '/catalogue_item';
    _navigationArguments = {'productId': relatedProductId};
    notifyListeners();
  }

  // Clear navigation flags
  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }
}