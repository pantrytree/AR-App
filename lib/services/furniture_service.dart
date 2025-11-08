import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_service.dart';
import '/models/furniture_item.dart';
import '/models/recently_viewed.dart';

class FurnitureService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Get All Furniture Items (with filters)
  Future<List<FurnitureItem>> getFurnitureItems({
    String? category,
    String? roomType,
    bool useFirestore = true,
  }) async {
    try {
      if (useFirestore) {
        Query<Map<String, dynamic>> query = _firestore.collection('furnitureItem');

        if (category != null && category != 'All') {
          query = query.where('category', isEqualTo: category);
        }

        if (roomType != null && roomType != 'All') {
          query = query.where('roomType', isEqualTo: roomType);
        }

        final snapshot = await query.get();

        return snapshot.docs
            .map((doc) => FurnitureItem.fromFirestore(doc))
            .toList();
      } else {
        String endpoint = '/furniture?';
        if (category != null) endpoint += 'category=$category&';
        if (roomType != null) endpoint += 'roomType=$roomType&';

        endpoint = endpoint.endsWith('&') || endpoint.endsWith('?')
            ? endpoint.substring(0, endpoint.length - 1)
            : endpoint;

        final response = await _apiService.get(endpoint);
        return (response as List<dynamic>)
            .map((json) => FurnitureItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load furniture items: $e');
    }
  }

  //  Stream furniture items (Real-time)
  Stream<List<FurnitureItem>> streamFurnitureItems({
    String? category,
    String? roomType,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('furnitureItem');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (roomType != null) {
      query = query.where('roomType', isEqualTo: roomType);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FurnitureItem.fromFirestore(doc))
          .toList();
    });
  }

  // Add to your FurnitureService class
  Stream<List<FurnitureItem>> streamItemsByRoomAndCategory(
      String roomType,
      String category, {
        String? excludeProductId,
        int limit = 4,
      }) {
    Query query = _firestore
        .collection('furnitureItem')
        .where('roomType', isEqualTo: roomType)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .limit(limit + 1);

    return query.snapshots().map((snapshot) {
      List<FurnitureItem> items = snapshot.docs
          .map((doc) => FurnitureItem.fromFirestore(doc))
          .toList();

      // Filter out excluded product if provided
      if (excludeProductId != null) {
        items = items.where((item) => item.id != excludeProductId).toList();
      }

      return items;
    });
  }

  // Get Single Furniture Item
  Future<FurnitureItem> getFurnitureItem(String id, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final doc = await _firestore.collection('furnitureItem').doc(id).get();

        if (!doc.exists) {
          throw Exception('Furniture item not found');
        }

        return FurnitureItem.fromFirestore(doc);
      } else {
        final response = await _apiService.get('/furniture/$id');
        return FurnitureItem.fromJson(response as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to load furniture item: $e');
    }
  }

  //  Stream single furniture item
  Stream<FurnitureItem?> streamFurnitureItem(String id) {
    return _firestore
        .collection('furnitureItem')
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return FurnitureItem.fromFirestore(doc);
    });
  }

  //  Search Furniture
  Future<List<FurnitureItem>> searchFurniture(String query, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final snapshot = await _firestore.collection('furnitureItem').get();

        return snapshot.docs
            .map((doc) => FurnitureItem.fromFirestore(doc))
            .where((item) {
          final searchQuery = query.toLowerCase();
          return item.name.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery) ||
              item.category.toLowerCase().contains(searchQuery);
        })
            .toList();
      } else {
        final response = await _apiService.get('/furniture/search?q=$query');
        return (response as List<dynamic>)
            .map((json) => FurnitureItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to search furniture: $e');
    }
  }

//  Get Recently Viewed Items
  Future<List<FurnitureItem>> getRecentlyViewed() async {
    try {
      final userId = _auth.currentUser?.uid;
      print('Getting recently viewed for user: $userId');

      if (userId == null) {
        print('User not authenticated');
        throw Exception('User not authenticated');
      }

      // Query the recently_viewed
      print('Querying: users/$userId/recently_viewed');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recently_viewed')
          .orderBy('viewedAt', descending: true)
          .limit(10)
          .get();

      print('Found ${snapshot.docs.length} recently viewed documents');

      if (snapshot.docs.isEmpty) {
        print('No recently viewed items');
        return [];
      }

      // Extract item IDs from recently_viewed
      final itemIds = <String>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('Recently viewed doc: ${doc.id}, data: $data');

        // The document ID IS the itemId in the recently_viewed
        final itemId = doc.id;
        itemIds.add(itemId);
        print('   - Item ID: $itemId');
      }

      print('Recently viewed item IDs: $itemIds');

      List<FurnitureItem> items = [];
      for (String itemId in itemIds) {
        try {
          print('Fetching furniture item: $itemId');

          final itemDoc = await _firestore
              .collection('furnitureItem')
              .doc(itemId)
              .get();

          if (itemDoc.exists) {
            final item = FurnitureItem.fromFirestore(itemDoc);
            items.add(item);
            print('Added: ${item.name}');
          } else {
            print('Furniture item not found: $itemId');
          }
        } catch (e) {
          print('Error fetching item $itemId: $e');
          continue;
        }
      }

      print('Returning ${items.length} recently viewed items');
      return items;
    } catch (e) {
      print('Failed to load recently viewed: $e');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to load recently viewed: $e');
    }
  }

//  Track Item View
  Future<void> trackItemView(String itemId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Cannot track view - user not authenticated');
        return;
      }

      print('Tracking view for item: $itemId by user: $userId');

      // Check current view count
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('recently_viewed')
          .doc(itemId);

      final existingDoc = await docRef.get();

      final recentlyViewed = RecentlyViewed(
        itemId: itemId,
        userId: userId,
        viewedAt: DateTime.now(),
        viewCount: existingDoc.exists
            ? ((existingDoc.data()?['viewCount'] ?? 0) as int) + 1
            : 1,
      );

      await docRef.set(
        recentlyViewed.toFirestore(),
        SetOptions(merge: true),
      );

      print('View tracked successfully');
      print(' Path: users/$userId/recently_viewed/$itemId');
    } catch (e) {
      print('Failed to track view: $e');
    }
  }

  //  Get Featured Items
  Future<List<FurnitureItem>> getFeaturedItems({bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final snapshot = await _firestore
            .collection('furnitureItem')
            .where('featured', isEqualTo: true)
            .limit(10)
            .get();

        return snapshot.docs
            .map((doc) => FurnitureItem.fromFirestore(doc))
            .toList();
      } else {
        final response = await _apiService.get('/furniture/featured');
        return (response as List<dynamic>)
            .map((json) => FurnitureItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load featured items: $e');
    }
  }

  //  Get Items by Room
  Future<List<FurnitureItem>> getItemsByRoom(String roomType, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final snapshot = await _firestore
            .collection('furnitureItem')
            .where('roomType', isEqualTo: roomType)
            .get();

        return snapshot.docs
            .map((doc) => FurnitureItem.fromFirestore(doc))
            .toList();
      } else {
        final response = await _apiService.get('/furniture/room/$roomType');
        return (response as List<dynamic>)
            .map((json) => FurnitureItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load items by room: $e');
    }
  }

  //  Get items by category
  Future<List<FurnitureItem>> getItemsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('furnitureItem')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => FurnitureItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load items by category: $e');
    }
  }

  //  Get furniture count
  Future<int> getFurnitureCount() async {
    try {
      final snapshot = await _firestore
          .collection('furnitureItem')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get all categories
  Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection('furnitureItem').get();

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null)
          .toSet()
          .toList();

      return categories.cast<String>();
    } catch (e) {
      return [];
    }
  }

  // Get all room types
  Future<List<String>> getAllRoomTypes() async {
    try {
      final snapshot = await _firestore.collection('furnitureItem').get();

      final roomTypes = snapshot.docs
          .map((doc) => doc.data()['roomType'] as String?)
          .where((roomType) => roomType != null)
          .toSet()
          .toList();

      return roomTypes.cast<String>();
    } catch (e) {
      return [];
    }
  }

  // Create Furniture Item
  Future<String> createFurnitureItem({
    required String name,
    required String description,
    required String category,
    required String roomType,
    String? imageUrl,
    List<String>? images,
    String? dimensions,
    String? color,
    bool featured = false,
    String? arModelUrl,
  }) async {
    try {
      final now = DateTime.now();
      final furnitureItem = FurnitureItem(
        id: '',
        name: name,
        description: description,
        category: category,
        roomType: roomType,
        imageUrl: imageUrl,
        images: images,
        dimensions: dimensions,
        color: color,
        featured: featured,
        createdAt: now,
        updatedAt: now,
        arModelUrl: arModelUrl,
      );

      final docRef = await _firestore
          .collection('furnitureItem')
          .add(furnitureItem.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create furniture item: $e');
    }
  }

  //  Update Furniture Item
  Future<void> updateFurnitureItem(
      String id, {
        String? name,
        String? description,
        String? category,
        String? roomType,
        String? imageUrl,
        List<String>? images,
        String? dimensions,
        String? color,
        bool? featured,
        String? arModelUrl,
      }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;
      if (roomType != null) updates['roomType'] = roomType;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;
      if (images != null) updates['images'] = images;
      if (dimensions != null) updates['dimensions'] = dimensions;
      if (color != null) updates['color'] = color;
      if (featured != null) updates['featured'] = featured;
      if (arModelUrl != null) updates['arModelUrl'] = arModelUrl;

      await _firestore.collection('furnitureItem').doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update furniture item: $e');
    }
  }

  //  Delete Furniture Item
  Future<void> deleteFurnitureItem(String id) async {
    try {
      await _firestore.collection('furnitureItem').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete furniture item: $e');
    }
  }

  //  Batch create furniture items
  Future<void> batchCreateFurnitureItems(List<FurnitureItem> items) async {
    try {
      final batch = _firestore.batch();

      for (var item in items) {
        final docRef = _firestore.collection('furnitureItem').doc();
        batch.set(docRef, item.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create furniture items: $e');
    }
  }
}
