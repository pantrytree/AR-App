import 'package:flutter/material.dart';
import '../../models/furniture_model.dart';
import '../../services/furniture_service.dart';
import '../../utils/filter_options.dart';

enum SearchResultType {
  furniture,
  room,
  category,
  likes,
  settings,
  help,
  about,
  ar
}

class SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;
  final SearchResultType type;
  final String? data;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    this.data,
  });
}

class HomeViewModel extends ChangeNotifier {
  // Existing properties
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;
  int _selectedIndex = 0;
  String? _navigateToRoute;
  dynamic _navigationArguments;

  // Search properties
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<SearchResult> _searchResults = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  int get selectedIndex => _selectedIndex;
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;

  // Search getters
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  List<SearchResult> get searchResults => _searchResults;

  HomeViewModel() {
    _initializeHomePage();
  }

  void _initializeHomePage() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate loading user data
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = {
        'displayName': 'Bulelwa',
        'email': 'bulelwa@example.com'
      };
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load home page';
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshHomePage() {
    _errorMessage = null;
    _initializeHomePage();
  }

  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();

    switch (index) {
      case 0: // Home
        break;
      case 1: // Favorites
        _navigateToRoute = '/my_likes_page';
        break;
      case 2: // AR View - Updated to use correct route name
        _navigateToRoute = '/camera_page';
        break;
      case 3: // Catalogue
        _navigateToRoute = '/catalogue';
        break;
      case 4: // Profile
        _navigateToRoute = '/profile';
        break;
    }
    notifyListeners();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }

  // Search functionality
  void performSearch(String query) {
    _searchQuery = query.trim();
    _isSearching = _searchQuery.isNotEmpty;

    if (!_isSearching) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _searchResults.clear();

    // Search furniture
    final furnitureResults = FurnitureService.allFurniture.where((furniture) {
      return furniture.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          furniture.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          furniture.furnitureType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          furniture.roomCategory.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    for (var furniture in furnitureResults.take(5)) {
      _searchResults.add(SearchResult(
        title: furniture.name,
        subtitle: '${furniture.roomCategory} • ${furniture.furnitureType}',
        icon: _getFurnitureIcon(furniture.furnitureType),
        type: SearchResultType.furniture,
      ));
    }

    // Search rooms
    final roomResults = FilterOptions.roomCardOptions.where((room) {
      return room['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    for (var room in roomResults) {
      final filterOption = room['filterOption'] as FilterOption;
      _searchResults.add(SearchResult(
        title: room['name'],
        subtitle: 'Room Category',
        icon: room['icon'],
        type: SearchResultType.room,
        data: filterOption.value,
      ));
    }

    // Search categories
    final categoryResults = ['bed', 'sofa', 'chair', 'table', 'lamp', 'wardrobe'].where((category) {
      return category.contains(_searchQuery.toLowerCase());
    }).toList();

    for (var category in categoryResults) {
      _searchResults.add(SearchResult(
        title: '${category[0].toUpperCase()}${category.substring(1)}s',
        subtitle: 'Furniture Type',
        icon: _getFurnitureIcon(category),
        type: SearchResultType.category,
        data: category,
      ));
    }

    // Search app features
    final featureResults = [
      {'title': 'My Likes', 'subtitle': 'View your favorite furniture', 'type': SearchResultType.likes, 'icon': Icons.favorite},
      {'title': 'Settings', 'subtitle': 'App settings and preferences', 'type': SearchResultType.settings, 'icon': Icons.settings},
      {'title': 'Help & Support', 'subtitle': 'Get help and FAQs', 'type': SearchResultType.help, 'icon': Icons.help},
      {'title': 'About App', 'subtitle': 'App information and version', 'type': SearchResultType.about, 'icon': Icons.info},
      {'title': 'AR Studio', 'subtitle': 'Augmented Reality furniture placement', 'type': SearchResultType.ar, 'icon': Icons.camera_alt},
    ].where((feature) {
      return feature['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          feature['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    for (var feature in featureResults) {
      _searchResults.add(SearchResult(
        title: feature['title'] as String,
        subtitle: feature['subtitle'] as String,
        icon: feature['icon'] as IconData,
        type: feature['type'] as SearchResultType,
      ));
    }

    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _isSearching = false;
    _searchResults.clear();
    notifyListeners();
  }

  IconData _getFurnitureIcon(String furnitureType) {
    switch (furnitureType.toLowerCase()) {
      case 'bed':
        return Icons.bed;
      case 'sofa':
        return Icons.weekend;
      case 'chair':
        return Icons.chair;
      case 'table':
        return Icons.table_restaurant;
      case 'lamp':
        return Icons.lightbulb;
      case 'wardrobe':
        return Icons.king_bed;
      default:
        return Icons.chair;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}