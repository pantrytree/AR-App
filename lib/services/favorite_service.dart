// lib/services/furniture_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/furniture_item.dart' as app_furniture;

class FurnitureService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recently used furniture items
  static Future<List<app_furniture.FurnitureItem>> getRecentlyUsedItems() async {
    try {
      // TODO: You might want to track usage in a separate collection
      // For now, we'll get the most recently created items
      final querySnapshot = await _firestore
          .collection('furniture_items')
          .orderBy('createdAt', descending: true)
          .limit(4)
          .get();

      return querySnapshot.docs
          .map((doc) => app_furniture.FurnitureItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting recently used items: $e');
      return [];
    }
  }

  // Get room categories from Design model room types
  static Future<List<Map<String, String>>> getRoomCategories() async {
    // Using the room types from the Design model
    const roomTypes = [
      {'title': 'Living Room', 'id': 'living_room'},
      {'title': 'Bedroom', 'id': 'bedroom'},
      {'title': 'Kitchen', 'id': 'kitchen'},
      {'title': 'Bathroom', 'id': 'bathroom'},
      {'title': 'Office', 'id': 'office'},
      {'title': 'Dining Room', 'id': 'dining_room'},
    ];

    return roomTypes;
  }

  // Get furniture item by ID
  static Future<app_furniture.FurnitureItem?> getFurnitureItem(String id) async {
    try {
      final doc = await _firestore
          .collection('furniture_items')
          .doc(id)
          .get();

      return doc.exists ? app_furniture.FurnitureItem.fromFirestore(doc) : null;
    } catch (e) {
      debugPrint('Error getting furniture item: $e');
      return null;
    }
  }

  // Search furniture items
  static Future<List<app_furniture.FurnitureItem>> searchFurnitureItems(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('furniture_items')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query z')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => app_furniture.FurnitureItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error searching furniture items: $e');
      return [];
    }
  }

  // Get furniture items by category
  static Future<List<app_furniture.FurnitureItem>> getFurnitureByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('furniture_items')
          .where('category', isEqualTo: category)
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => app_furniture.FurnitureItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting furniture by category: $e');
      return [];
    }
  }
}