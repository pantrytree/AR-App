import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_service.dart';

class RoomService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get available room types with item counts from furniture_items collection
  Future<List<Map<String, dynamic>>> getRoomsWithCounts() async {
    try {
      // Get all furniture items
      final snapshot = await _firestore
          .collection('furnitureItem')
          .get();

      // Count items per room type
      final Map<String, int> roomCounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final roomType = data['roomType'] as String?;
        if (roomType != null && roomType.isNotEmpty) {
          roomCounts[roomType] = (roomCounts[roomType] ?? 0) + 1;
        }
      }

      final roomMetadata = {
        'Living Room': {
          'icon': 'weekend',
          'description': 'Comfortable living space furniture',
        },
        'Bedroom': {
          'icon': 'bed',
          'description': 'Bedroom furniture and accessories',
        },
        'Office': {
          'icon': 'work',
          'description': 'Office and workspace furniture',
        },
        'Kitchen': {
          'icon': 'kitchen',
          'description': 'Kitchen furniture and storage',
        },
        'Dining Room': {
          'icon': 'dining',
          'description': 'Dining room furniture sets',
        },
        'Bathroom': {
          'icon': 'bathtub',
          'description': 'Bathroom furniture and accessories',
        },
      };

      // Create room list with counts
      final rooms = roomCounts.entries.map((entry) {
        final roomType = entry.key;
        final count = entry.value;
        final metadata = roomMetadata[roomType] ?? {
          'icon': 'widgets',
          'description': '$roomType furniture',
        };

        return {
          'name': roomType,
          'itemCount': count,
          'icon': metadata['icon'],
          'description': metadata['description'],
        };
      }).toList();

      // Sort by name
      rooms.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      return rooms;
    } catch (e) {
      print('Error getting rooms with counts: $e');
      throw Exception('Failed to load rooms: $e');
    }
  }

  // Stream rooms with real-time count updates
  Stream<List<Map<String, dynamic>>> streamRoomsWithCounts() {
    return _firestore
        .collection('furnitureItem')
        .snapshots()
        .map((snapshot) {
      // Count items per room type
      final Map<String, int> roomCounts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final roomType = data['roomType'] as String?;
        if (roomType != null && roomType.isNotEmpty) {
          roomCounts[roomType] = (roomCounts[roomType] ?? 0) + 1;
        }
      }

      // Define room metadata
      final roomMetadata = {
        'Living Room': {
          'icon': 'weekend',
          'description': 'Comfortable living space furniture',
        },
        'Bedroom': {
          'icon': 'bed',
          'description': 'Bedroom furniture and accessories',
        },
        'Office': {
          'icon': 'work',
          'description': 'Office and workspace furniture',
        },
        'Kitchen': {
          'icon': 'kitchen',
          'description': 'Kitchen furniture and storage',
        },
        'Dining Room': {
          'icon': 'dining',
          'description': 'Dining room furniture sets',
        },
        'Bathroom': {
          'icon': 'bathtub',
          'description': 'Bathroom furniture and accessories',
        },
      };

      // Create room list
      final rooms = roomCounts.entries.map((entry) {
        final roomType = entry.key;
        final count = entry.value;
        final metadata = roomMetadata[roomType] ?? {
          'icon': 'widgets',
          'description': '$roomType furniture',
        };

        return {
          'name': roomType,
          'itemCount': count,
          'icon': metadata['icon'],
          'description': metadata['description'],
        };
      }).toList();

      // Sort by name
      rooms.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      return rooms;
    });
  }

  // Get all unique room types from furniture items
  Future<List<String>> getAllRoomTypes() async {
    try {
      final snapshot = await _firestore.collection('furnitureItem').get();

      final roomTypes = snapshot.docs
          .map((doc) => doc.data()['roomType'] as String?)
          .where((roomType) => roomType != null && roomType.isNotEmpty)
          .toSet()
          .toList();

      roomTypes.sort();
      return roomTypes.cast<String>();
    } catch (e) {
      print('Error getting room types: $e');
      return [];
    }
  }

  // Get total room count (unique room types)
  Future<int> getRoomCount() async {
    try {
      final roomTypes = await getAllRoomTypes();
      return roomTypes.length;
    } catch (e) {
      return 0;
    }
  }
}