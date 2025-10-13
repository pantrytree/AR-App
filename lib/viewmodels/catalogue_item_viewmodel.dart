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

  // ======================
  // BACKEND INTEGRATION POINTS
  // ======================

  // TODO: Backend - Implement loadProductData()
  // Description: Loads product details from products table
  // Expected: Populates product data fields
  void _loadProductData() {
    debugPrint("Loading product data for ID: $productId");
    // Backend team to implement:
    // - Query products table by productId
    // - Populate _productTitle, _productDimensions, _productDescription
    // - Load actual product image URLs
  }

  // TODO: Backend - Implement addToCart()
  // Description: Adds item to user's cart in cart_items table
  // Expected: Returns success status
  Future<void> _addToCartInBackend() async {
    // Backend team to implement:
    // - Insert record into cart_items table
    // - Associate with current user
    // - Return success status
    debugPrint("Adding $productTitle to cart - BACKEND NEEDED");
  }

  // TODO: Backend - Implement toggleFavorite()
  // Description: Toggles favorite status in user_favorites table
  // Expected: Returns updated favorite status
  Future<void> _toggleFavoriteInBackend() async {
    // Backend team to implement:
    // - Insert/delete record in user_favorites table
    // - Associate with current user and product
    // - Return updated favorite status
    debugPrint("Toggling favorite for $productTitle - BACKEND NEEDED");
  }

  // ======================
  // PUBLIC METHODS
  // ======================

  void addToCart() {
    debugPrint("Adding $productTitle to cart");
    // Backend team: This function needs implementation
    _addToCartInBackend();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
    debugPrint("${_isFavorite ? 'Added' : 'Removed'} $productTitle from favorites");
    // Backend team: This function needs implementation
    _toggleFavoriteInBackend();
  }

  void navigateToRelatedItem(String relatedProductId) {
    _navigateToRoute = '/catalogue_item';
    _navigationArguments = {'productId': relatedProductId};
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }
}