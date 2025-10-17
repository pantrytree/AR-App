import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/furniture_service.dart';
import '/services/favorites_service.dart';
import '/models/furniture_item.dart';

class CatalogueItemViewModel extends ChangeNotifier {
  final String? productId;
  final FurnitureService _furnitureService;
  final FavoritesService _favoritesService;

  // Stream subscriptions for real-time updates
  StreamSubscription<DocumentSnapshot>? _productStreamSubscription;
  StreamSubscription<QuerySnapshot>? _relatedItemsStreamSubscription;
  StreamSubscription<List<String>>? _favoritesStreamSubscription;

  CatalogueItemViewModel({
    required FurnitureService furnitureService,
    required FavoritesService favoritesService,
    this.productId,
  }) : _furnitureService = furnitureService,
        _favoritesService = favoritesService {
    if (productId != null) {
      _setupRealTimeListeners();
    }
  }

  // Product data
  FurnitureItem? _product;
  bool _isLoading = false;
  bool _isFavorite = false;
  String? _errorMessage;
  List<FurnitureItem> _relatedItems = [];
  List<FurnitureItem> _recommendedItems = [];

  // Navigation flags
  String? _navigateToRoute;
  Map<String, dynamic>? _navigationArguments;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FurnitureItem? get product => _product;
  String get productTitle => _product?.name ?? 'Loading...';
  String get productDimensions => _product?.dimensions ?? 'N/A';
  String get productDescription => _product?.description ?? 'Loading...';
  String? get productImageUrl => _product?.imageUrl;
  List<String>? get productImages => _product?.images;
  bool get isFavorite => _isFavorite;
  String? get arModelUrl => _product?.arModelUrl;
  String? get roomType => _product?.roomType;
  String? get category => _product?.category;
  bool get isFeatured => _product?.featured ?? false;

  // Related and recommended items
  List<FurnitureItem> get relatedItems => _relatedItems;
  List<FurnitureItem> get recommendedItems => _recommendedItems;

  // Convert to UI-compatible format
  List<Map<String, dynamic>> get relatedItemsForUI => _relatedItems.map((item) => {
    'id': item.id,
    'title': item.name,
    'dimensions': item.dimensions ?? 'N/A',
    'imageUrl': item.imageUrl,
    'roomType': item.roomType,
    'category': item.category,
  }).toList();

  List<Map<String, dynamic>> get recommendedItemsForUI => _recommendedItems.map((item) => {
    'id': item.id,
    'title': item.name,
    'dimensions': item.dimensions ?? 'N/A',
    'imageUrl': item.imageUrl,
    'roomType': item.roomType,
    'category': item.category,
  }).toList();

  String? get navigateToRoute => _navigateToRoute;
  Map<String, dynamic>? get navigationArguments => _navigationArguments;

  void _setupRealTimeListeners() {
    if (productId == null) return;

    // Use the furniture service's stream method
    _productStreamSubscription = _furnitureService.streamFurnitureItem(productId!).listen(
          (FurnitureItem? product) {
        if (product != null) {
          _product = product;
          notifyListeners();

          // Load related items when product data is available
          if (_product != null) {
            _loadRelatedItems();
            _loadRecommendedItems();
          }
        }
      },
      onError: (error) {
        print('Error in product stream: $error');
        _errorMessage = 'Failed to load product details';
        notifyListeners();
      },
    ) as StreamSubscription<DocumentSnapshot<Object?>>?;

    // Listen for favorites updates
    _favoritesStreamSubscription = _favoritesService.streamFavoriteIds().listen(
          (List<String> favoriteIds) {
        _isFavorite = favoriteIds.contains(productId);
        notifyListeners();
      },
      onError: (error) {
        print('Error in favorites stream: $error');
      },
    );
  }

  // Load related items from same room type
  Future<void> _loadRelatedItems() async {
    if (_product == null) return;

    try {
      // Use furniture service's stream method for related items
      _relatedItemsStreamSubscription = _furnitureService.streamItemsByRoomAndCategory(
        _product!.roomType,
        _product!.category,
        excludeProductId: productId,
        limit: 4,
      ).listen(
            (List<FurnitureItem> items) {
          _relatedItems = items;
          notifyListeners();
        },
        onError: (error) {
          print('Error loading related items: $error');
        },
      ) as StreamSubscription<QuerySnapshot<Object?>>?;
    } catch (e) {
      print('Error setting up related items stream: $e');
    }
  }

  // Load recommended items (featured or popular items)
  Future<void> _loadRecommendedItems() async {
    try {
      // Get featured items from same room type, excluding current product
      final recommended = await _furnitureService.getFeaturedItems();
      _recommendedItems = recommended
          .where((item) => item.id != productId)
          .take(4)
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading recommended items: $e');
      _recommendedItems = [];
    }
  }

  // Toggle favorite with real-time updates
  Future<void> toggleFavorite() async {
    if (productId == null) return;

    try {
      // Optimistic update
      final wasFavorite = _isFavorite;
      _isFavorite = !_isFavorite;
      notifyListeners();

      if (wasFavorite) {
        await _favoritesService.removeFromFavorites(productId!);
        print('Removed ${_product?.name} from favorites');
      } else {
        await _favoritesService.addToFavorites(productId!);
        print('Added ${_product?.name} to favorites');
      }
    } catch (e) {
      // Revert optimistic update on error
      _isFavorite = _isFavorite;
      notifyListeners();

      print('Error toggling favorite: $e');
      _errorMessage = 'Failed to update favorites';
      notifyListeners();
      rethrow;
    }
  }

  // Get similar products by multiple criteria
  Future<List<FurnitureItem>> getSimilarProducts() async {
    if (_product == null) return [];

    try {
      // Get items with similar style, price range, and category
      final similarItems = await _furnitureService.searchFurniture(
        _product!.category ?? _product!.color!,
      );

      return similarItems
          .where((item) => item.id != productId)
          .take(6)
          .toList();
    } catch (e) {
      print('Error getting similar products: $e');
      return [];
    }
  }

  // Navigation methods
  void openInAR() {
    if (_product == null) return;

    print('Opening ${_product!.name} in AR');
    _navigateToRoute = '/camera-page';
    _navigationArguments = {
      'productId': productId,
      'arModelUrl': arModelUrl,
      'productName': _product!.name,
      'productDimensions': _product!.dimensions,
    };
    notifyListeners();
  }

  void navigateToRelatedItem(String relatedProductId) {
    _navigateToRoute = '/catalogue-item';
    _navigationArguments = {'productId': relatedProductId};
    notifyListeners();
  }

  void navigateToRoom(String roomType) {
    _navigateToRoute = '/catalogue';
    _navigationArguments = {'initialRoom': roomType};
    notifyListeners();
  }

  void navigateToCategory(String category) {
    _navigateToRoute = '/catalogue';
    _navigationArguments = {'initialType': category};
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }

  // Refresh all data
  Future<void> refresh() async {
    if (productId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Force reload product data
      _product = await _furnitureService.getFurnitureItem(productId!);

      // Reload favorites status
      _isFavorite = await _favoritesService.isFavorite(productId!);

      // Reload related and recommended items
      await _loadRelatedItems();
      await _loadRecommendedItems();

      _errorMessage = null;
    } catch (e) {
      print('Error refreshing product data: $e');
      _errorMessage = 'Failed to refresh product details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _productStreamSubscription?.cancel();
    _relatedItemsStreamSubscription?.cancel();
    _favoritesStreamSubscription?.cancel();
    super.dispose();
  }
}