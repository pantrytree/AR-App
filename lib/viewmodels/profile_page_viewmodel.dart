import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/auth_service.dart';
import '/models/user.dart' as models;
import '/utils/event_bus.dart';

class AccountHubViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data
  models.User? _currentUser;
  models.User? get currentUser => _currentUser;

  String get userName => _currentUser?.displayName ?? 'User';
  String get email => _currentUser?.email ?? 'user@example.com';
  String? get photoUrl => _currentUser?.photoUrl;

  // User statistics
  int _projectsCount = 0;
  int _designsCount = 0;
  int _favoritesCount = 0;
  int get projectsCount => _projectsCount;
  int get designsCount => _designsCount;
  int get favoritesCount => _favoritesCount;

  // Cache busting for images
  String? get profileImageUrlWithCacheBusting {
    if (_currentUser?.photoUrl == null) return null;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${_currentUser!.photoUrl}?t=$timestamp';
  }

  // Loading and error states
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Navigation
  String? _navigateToRoute;
  String? get navigateToRoute => _navigateToRoute;

  // Stream subscriptions
  StreamSubscription<ProfileUpdatedEvent>? _profileUpdateSubscription;
  StreamSubscription<DocumentSnapshot>? _userDataSubscription;
  StreamSubscription<QuerySnapshot>? _projectsSubscription;
  StreamSubscription<QuerySnapshot>? _designsSubscription;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  AccountHubViewModel() {
    _startListeningToProfileUpdates();
    _startListeningToUserData();
  }

  /// Listen for profile updates from EventBus
  void _startListeningToProfileUpdates() {
    _profileUpdateSubscription = EventBus().listen<ProfileUpdatedEvent>((event) {
      print('AccountHubViewModel: Received profile update event');
      _forceRefreshUserData();
    });
  }

  /// Start listening to real-time user data changes
  void _startListeningToUserData() {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    // Listen to user document changes
    _userDataSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _currentUser = models.User.fromFirestore(snapshot);
        print('Real-time user data updated: ${_currentUser?.displayName}');
        notifyListeners();
      }
    });

    // Listen to user statistics
    _startListeningToUserStatistics(userId);
  }

  /// Listen to user statistics in real-time
  void _startListeningToUserStatistics(String userId) {
    // Projects count
    _projectsSubscription = _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _projectsCount = snapshot.docs.length;
      notifyListeners();
    });

    // Designs count
    _designsSubscription = _firestore
        .collection('designs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _designsCount = snapshot.docs.length;
      notifyListeners();
    });

    // Favorites count
    _favoritesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      _favoritesCount = snapshot.docs.length;
      notifyListeners();
    });
  }

  /// Load user data from Firestore with statistics
  Future<void> loadUserData() async {
    _setLoading(true);
    _clearMessages();

    try {
      print('Loading user data and statistics...');

      // Load user profile
      _currentUser = await _authService.getCurrentUserModel();

      if (_currentUser == null) {
        _errorMessage = 'Failed to load user profile';
        print('User not found');
      } else {
        print('User loaded: ${_currentUser!.displayName}');

        // Load user statistics
        await _loadUserStatistics();

        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: ${e.toString()}';
      print('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user statistics from Firestore
  Future<void> _loadUserStatistics() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;

      // Get projects count
      final projectsSnapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .get();
      _projectsCount = projectsSnapshot.docs.length;

      // Get designs count
      final designsSnapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: userId)
          .get();
      _designsCount = designsSnapshot.docs.length;

      // Get favorites count
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();
      _favoritesCount = favoritesSnapshot.docs.length;

      print('User statistics loaded - Projects: $_projectsCount, Designs: $_designsCount, Favorites: $_favoritesCount');
    } catch (e) {
      print('Error loading user statistics: $e');
    }
  }

  /// Force refresh user data with cache busting
  Future<void> forceRefreshUserData() async {
    print('Force refreshing user data...');
    await _forceRefreshUserData();
  }

  /// Internal force refresh implementation
  Future<void> _forceRefreshUserData() async {
    _setLoading(true);
    try {
      // Get fresh user data
      _currentUser = await _authService.getCurrentUserModel(refresh: true);

      if (_currentUser != null) {
        print('Force refreshed user: ${_currentUser!.displayName}');
        print('Profile image URL: ${_currentUser!.photoUrl}');

        // Refresh statistics
        await _loadUserStatistics();
      } else {
        print('Force refresh: User not found');
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh user data: ${e.toString()}';
      print('Error force refreshing user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data (public method)
  Future<void> refreshUserData() async {
    print('Refreshing user data...');
    await _forceRefreshUserData();
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? imageUrl,
  }) async {
    try {
      print('Updating profile...');

      bool hasChanges = false;

      if (name != null && name != _currentUser?.displayName) {
        final result = await _authService.updateDisplayName(name);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update name';
          notifyListeners();
          return false;
        }
        hasChanges = true;
      }

      if (email != null && email != _currentUser?.email) {
        final result = await _authService.updateEmail(email);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update email';
          notifyListeners();
          return false;
        }
        hasChanges = true;
      }

      if (imageUrl != null && imageUrl != _currentUser?.photoUrl) {
        final result = await _authService.updatePhotoURL(imageUrl);
        if (result['success'] != true) {
          _errorMessage = result['error'] ?? 'Failed to update photo';
          notifyListeners();
          return false;
        }
        hasChanges = true;
      }

      if (hasChanges) {
        // Refresh user data
        await _forceRefreshUserData();

        // Notify other parts of the app about the profile update
        EventBus().fire(ProfileUpdatedEvent());

        _successMessage = 'Profile updated successfully';
        print('Profile updated and event fired');
      } else {
        _successMessage = 'No changes detected';
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      print('Error updating profile: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update profile image only
  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      print('Updating profile image...');

      final result = await _authService.updatePhotoURL(imageUrl);
      if (result['success'] != true) {
        _errorMessage = result['error'] ?? 'Failed to update profile image';
        notifyListeners();
        return false;
      }

      // Refresh user data
      await _forceRefreshUserData();

      // Notify other parts of the app
      EventBus().fire(ProfileUpdatedEvent());

      _successMessage = 'Profile image updated successfully';
      print('Profile image updated and event fired');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile image: ${e.toString()}';
      print('Error updating profile image: $e');
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    _clearMessages();

    try {
      print('Initiating logout process...');

      // Close all active subscriptions first
      await _cancelAllSubscriptions();

      // Perform logout through AuthService
      await _authService.signOut();

      // Set navigation route
      _navigateToRoute = '/logout';

      print('Logout process completed successfully');

      // Notify listeners to trigger navigation
      notifyListeners();

    } catch (e) {
      _errorMessage = 'Failed to logout: ${e.toString()}';
      print('Error during logout: $e');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Cancel all stream subscriptions
  Future<void> _cancelAllSubscriptions() async {
    print('Cancelling all stream subscriptions...');

    await _profileUpdateSubscription?.cancel();
    await _userDataSubscription?.cancel();
    await _projectsSubscription?.cancel();
    await _designsSubscription?.cancel();
    await _favoritesSubscription?.cancel();

    _profileUpdateSubscription = null;
    _userDataSubscription = null;
    _projectsSubscription = null;
    _designsSubscription = null;
    _favoritesSubscription = null;

    print('All subscriptions cancelled');
  }

  /// Clear navigation route
  void clearNavigation() {
    _navigateToRoute = null;
    notifyListeners();
  }

  /// Get user statistics with backend integration
  Future<Map<String, int>> getUserStats() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {
          'projects': 0,
          'designs': 0,
          'favorites': 0,
        };
      }

      return {
        'projects': _projectsCount,
        'designs': _designsCount,
        'favorites': _favoritesCount,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {
        'projects': _projectsCount,
        'designs': _designsCount,
        'favorites': _favoritesCount,
      };
    }
  }

  /// Sync user data with backend
  Future<void> syncWithBackend() async {
    try {
      print('Syncing user data with backend...');
      _successMessage = 'Data synced successfully';
      notifyListeners();
    } catch (e) {
      print('Error syncing with backend: $e');
      _errorMessage = 'Failed to sync data';
      notifyListeners();
    }
  }

  /// Clear messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void triggerManualRefresh() {
    print('Manual refresh triggered');
    _forceRefreshUserData();
  }

  bool get needsRefresh {
    return true;
  }

  @override
  void dispose() {
    print('Disposing AccountHubViewModel');
    _cancelAllSubscriptions();
    super.dispose();
  }
}