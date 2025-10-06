// catalogue_item_viewmodel.dart
import 'package:flutter/material.dart';
import '../views/catalogue_item_page.dart';
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

  // Load product data
  void _loadProductData() {
    print("Loading product data for ID: $productId");
  }

  // Add to cart functionality
  void addToCart() {
    print("Adding $productTitle to cart");
  }

  // Toggle favorite status
  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
    print("${_isFavorite ? 'Added' : 'Removed'} $productTitle from favorites");
  }

  // Navigate to related item
  void navigateToRelatedItem(BuildContext context, String relatedProductId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatalogueItemPage(productId: relatedProductId),
      ),
    );
  }
}