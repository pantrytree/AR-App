import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/furniture_service.dart';
import '/services/room_service.dart';
import '/services/project_service.dart';
import '/services/auth_service.dart';
import '/models/furniture_item.dart';
import '/models/project.dart';
import '/models/user.dart' as models;

class HomeViewModel extends ChangeNotifier {
  final FurnitureService _furnitureService;
  final RoomService _roomService;
  final ProjectService _projectService;
  final AuthService _authService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static HomeViewModel? _instance;
  static HomeViewModel get instance {
    _instance ??= HomeViewModel(
      furnitureService: FurnitureService(),
      roomService: RoomService(),
      projectService: ProjectService(),
      authService: AuthService(),
    );
    return _instance!;
  }

  HomeViewModel({
    required FurnitureService furnitureService,
    required RoomService roomService,
    required ProjectService projectService,
    required AuthService authService,
  })  : _furnitureService = furnitureService,
        _roomService = roomService,
        _projectService = projectService,
        _authService = authService {
    _initialize();
  }

  // Stream subscriptions
  StreamSubscription<List<Map<String, dynamic>>>? _roomsStreamSubscription;
  StreamSubscription<DocumentSnapshot>? _userProfileSubscription;

  // State
  bool _isLoading = false;
  bool _isUserDataLoaded = false;
  bool get isUserDataLoaded => _isUserDataLoaded;
  bool _hasError = false;
  String? _errorMessage;
  bool _disposed = false;
  int _selectedIndex = 0;

  // Real data properties
  models.User? _currentUser;
  List<FurnitureItem> _recentlyViewedItems = [];
  List<Project> _userProjects = [];
  List<Map<String, dynamic>> _rooms = [];
  String _userDisplayName = 'User';
  String? _userPhotoUrl;

  // Navigation
  String? _navigateToRoute;
  dynamic _navigationArguments;

  // Getters
  String? get navigateToRoute => _navigateToRoute;
  dynamic get navigationArguments => _navigationArguments;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get selectedIndex => _selectedIndex;
  String get userName => _userDisplayName;
  String get userDisplayName => _userDisplayName;
  String? get userPhotoUrl => _userPhotoUrl;
  models.User? get currentUser => _currentUser;
  List<FurnitureItem> get recentlyViewedItems => _recentlyViewedItems;
  List<Map<String, dynamic>> get rooms => _rooms;

  // Data getters for UI compatibility
  List<Map<String, dynamic>> get recentlyUsedItems {
    return _recentlyViewedItems.map((item) => {
      'id': item.id,
      'name': item.name,
      'imageUrl': item.imageUrl,
      'roomType': item.roomType,
      'category': item.category,
    }).toList();
  }

  // Room categories - using the dynamically loaded rooms
  List<Map<String, dynamic>> get roomCategories {
    return _rooms.map((room) => {
      'id': room['name'],
      'name': room['name'] as String,
      'category': (room['name'] as String).toLowerCase().replaceAll(' ', '_'),
      'imageUrl': null,
      'itemCount': '${room['itemCount']}${(room['itemCount'] as int) >= 10 ? '+' : ''}',
      'icon': room['icon'],
    }).toList();
  }

  // User projects (separate for other uses)
  List<Map<String, dynamic>> get userProjects {
    return _userProjects.map((project) => {
      'id': project.id,
      'name': project.name,
      'roomType': project.roomType,
      'imageUrl': project.imageUrl,
    }).toList();
  }

  // Available room types
  List<Map<String, String>> get availableRoomTypes {
    return _rooms.map((room) => {
      'id': room['name'] as String,
      'name': room['name'] as String,
      'type': room['name'] as String,
    }).toList();
  }

  void resetToHome() {
    _selectedIndex = 0;
    _navigateToRoute = null;
    _navigationArguments = null;
    notifyListeners();
  }

  void _initialize() {
    _loadUserProfile();
    _loadRecentlyViewed();
    _setupRoomsStream();
    _setupUserProfileStream();
    _loadUserProjects();
  }

  // Setup real-time stream for user profile
  void _setupUserProfileStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _userProfileSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data();
          _userDisplayName = data?['displayName'] as String? ??
              data?['name'] as String? ??
              _auth.currentUser?.displayName ??
              'User';
          _userPhotoUrl = data?['photoUrl'] as String? ??
              data?['profilePicture'] as String? ??
              _auth.currentUser?.photoURL;
          notifyListeners();
        }
      },
      onError: (error) {
        print('Error in user profile stream: $error');
      },
    );
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _userDisplayName = 'Guest';
        _isUserDataLoaded = true;
        return;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        _userDisplayName = data?['displayName'] as String? ??
            data?['name'] as String? ??
            _auth.currentUser?.displayName ??
            'User';
        _userPhotoUrl = data?['photoUrl'] as String? ??
            data?['profilePicture'] as String? ??
            _auth.currentUser?.photoURL;
      } else {
        _userDisplayName = _auth.currentUser?.displayName ?? 'User';
        _userPhotoUrl = _auth.currentUser?.photoURL;
      }

      _currentUser = await _authService.getCurrentUserModel();
      _isUserDataLoaded = true;

      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
      _userDisplayName = _auth.currentUser?.displayName ?? 'User';
    }
  }

  void _setupRoomsStream() {
    _roomsStreamSubscription = _roomService.streamRoomsWithCounts().listen(
          (rooms) {
        _rooms = rooms;
        notifyListeners();
      },
      onError: (error) {
        print('Error in rooms stream: $error');
        _errorMessage = 'Failed to load rooms';
        notifyListeners();
      },
    );
  }

  // Load recently viewed items using the RecentlyViewed model
  Future<void> _loadRecentlyViewed() async {
    try {
      print('Loading recently viewed items...');
      _recentlyViewedItems = await _furnitureService.getRecentlyViewed();
      print('Loaded ${_recentlyViewedItems.length} recently viewed items');
      notifyListeners();
    } catch (e) {
      print('Error loading recently viewed: $e');
      _recentlyViewedItems = [];
    }
  }

  // Load user projects
  Future<void> _loadUserProjects() async {
    try {
      _userProjects = await _projectService.getProjects();
      print('Loaded ${_userProjects.length} user projects');
      notifyListeners();
    } catch (e) {
      print('Error fetching projects: $e');
      _userProjects = [];
    }
  }

  // Initialize - called on first load
  Future<void> initialize() async {
    await refreshHomePage();
  }

  // Refresh all data
  Future<void> refresh() async {
    await refreshHomePage();
  }

  // Refresh home page data - calls all backend functions
  Future<void> refreshHomePage() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    _isUserDataLoaded = false;

    notifyListeners();

    try {
      print('Refreshing home page data...');

      await Future.wait([
        _loadUserProfile(),
        _loadRecentlyViewed(),
        _loadUserProjects(),
      ]);

      _isLoading = false;
      _errorMessage = null;
      print('Home page data loaded successfully');
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load home page data';
      print('Error refreshing home page: $e');
      notifyListeners();
    }
  }

  // Track item view (for recently viewed)
  Future<void> trackItemView(String itemId) async {
    try {
      await _furnitureService.trackItemView(itemId);
      await _loadRecentlyViewed();
    } catch (e) {
      print('Error tracking item view: $e');
    }
  }

  /// Get featured furniture items
  Future<List<FurnitureItem>> getFeaturedItems() async {
    try {
      return await _furnitureService.getFeaturedItems();
    } catch (e) {
      print('Error getting featured items: $e');
      return [];
    }
  }

  /// Get furniture items by room type
  Future<List<FurnitureItem>> getItemsByRoomType(String roomType) async {
    try {
      return await _furnitureService.getItemsByRoom(roomType);
    } catch (e) {
      print('Error getting items by room type: $e');
      return [];
    }
  }

  // Bottom navigation method
  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();

    switch (index) {
      case 0: // Home
        refreshHomePage();
        break;
      case 1: // Favorites
        _navigateToRoute = '/my-likes';
        notifyListeners();
        break;
      case 2: // AR View (Camera)
        _navigateToRoute = '/camera-page';
        notifyListeners();
        break;
      case 3:
        _navigateToRoute = '/catalogue';
        notifyListeners();
        break;
      case 4: // Profile
        _navigateToRoute = '/account-hub';
        notifyListeners();
        break;
    }
  }

  // Navigate to furniture catalogue with room filter
  void navigateToRoomCatalogue(String roomType) {
    _navigateToRoute = '/catalogue';
    _navigationArguments = {'initialRoom': roomType};
    notifyListeners();
  }

  // Navigate to furniture item details
  void navigateToFurnitureItem(String itemId) {
    _navigateToRoute = '/catalogue-item';
    _navigationArguments = {'productId': itemId};
    notifyListeners();

    // Track the view
    trackItemView(itemId);
  }

  // Navigate to full catalogue
  void navigateToCatalogue() {
    _navigateToRoute = '/catalogue';
    _navigationArguments = null;
    notifyListeners();
  }

  // Navigation methods for compatibility
  void onSearchTapped() {
    _navigateToRoute = '/search';
    notifyListeners();
  }

  void onFurnitureItemTapped(String id) {
    navigateToFurnitureItem(id);
  }

  // Room tapped - navigate to catalogue with room filter
  void onRoomTapped(String roomType) {
    navigateToRoomCatalogue(roomType);
  }

  // Category tapped - navigate to catalogue with room filter
  void onCategoryTapped(String category) {
    final roomType = category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
    navigateToRoomCatalogue(roomType);
  }

  // All categories - navigate to full catalogue
  void onAllCategoriesTapped() {
    navigateToCatalogue();
  }

  void onShoppingBagTapped() {
    navigateToCatalogue();
  }

  void clearNavigation() {
    _navigateToRoute = null;
    _navigationArguments = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  /// Retry loading data after error
  Future<void> retryLoad() async {
    await refreshHomePage();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _roomsStreamSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}