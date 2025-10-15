import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_service.dart';
import '/models/favorite.dart';
import '/models/furniture_item.dart';

class FavoritesService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get User's Favorites (Returns FurnitureItem models)
  // Endpoint: GET /api/favorites

  Future<List<FurnitureItem>> getFavorites({bool useFirestore = true}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (useFirestore) {
        // Get favorite item IDs
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .orderBy('createdAt', descending: true)
            .get();

        if (snapshot.docs.isEmpty) {
          return [];
        }

        // Get furniture items for those IDs
        final itemIds = snapshot.docs.map((doc) => doc.id).toList();

        List<FurnitureItem> items = [];
        for (String itemId in itemIds) {
          try {
            final itemDoc = await _firestore.collection('furniture_items').doc(itemId).get();
            if (itemDoc.exists) {
              items.add(FurnitureItem.fromFirestore(itemDoc));
            }
          } catch (e) {
            print('Error fetching item $itemId: $e');
            continue;
          }
        }

        return items;
      } else {
        final response = await _apiService.get('/favorites', requiresAuth: true);
        return (response as List<dynamic>)
            .map((json) => FurnitureItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  // Stream favorites (Real-time updates - returns item IDs)
  Stream<List<String>> streamFavoriteIds() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
  // 2. Add to Favorites
  // Endpoint: POST /api/favorites

  Future<void> addToFavorites(String itemId, {bool useFirestore = true}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (useFirestore) {
        final favorite = Favorite(
          itemId: itemId,
          userId: userId,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(itemId)
            .set(favorite.toFirestore());
      } else {
        await _apiService.post(
          '/favorites',
          body: {'itemId': itemId},
          requiresAuth: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // 3. Remove from Favorites
  // Endpoint: DELETE /api/favorites/:itemId

  Future<void> removeFromFavorites(String itemId, {bool useFirestore = true}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (useFirestore) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(itemId)
            .delete();
      } else {
        await _apiService.delete('/favorites/$itemId', requiresAuth: true);
      }
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // 4. Check if Item is Favorite
  // Endpoint: GET /api/favorites/check/:itemId

  Future<bool> isFavorite(String itemId, {bool useFirestore = true}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      if (useFirestore) {
        final doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(itemId)
            .get();

        return doc.exists;
      } else {
        final response = await _apiService.get(
          '/favorites/check/$itemId',
          requiresAuth: true,
        );
        return response['isFavorite'] ?? false;
      }
    } catch (e) {
      return false;
    }
  }

  // 5. Toggle favorite (add if not favorite, remove if favorite)

  Future<bool> toggleFavorite(String itemId) async {
    try {
      final isFav = await isFavorite(itemId);

      if (isFav) {
        await removeFromFavorites(itemId);
        return false;
      } else {
        await addToFavorites(itemId);
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // 6. Get favorite count

  Future<int> getFavoriteCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // 7. Clear all favorites

  Future<void> clearAllFavorites() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear favorites: $e');
    }
  }

  // 8. Get favorites by category

  Future<List<FurnitureItem>> getFavoritesByCategory(String category) async {
    try {
      final favorites = await getFavorites();
      return favorites.where((item) => item.category == category).toList();
    } catch (e) {
      throw Exception('Failed to load favorites by category: $e');
    }
  }

  // 9. Get favorites by room type

  Future<List<FurnitureItem>> getFavoritesByRoomType(String roomType) async {
    try {
      final favorites = await getFavorites();
      return favorites.where((item) => item.roomType == roomType).toList();
    } catch (e) {
      throw Exception('Failed to load favorites by room type: $e');
    }
  }
}