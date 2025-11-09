import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a user's favorite item with basic metadata
class Favorite {
  final String itemId;      
  final String userId;      
  final DateTime createdAt; 

  Favorite({
    required this.itemId,
    required this.userId,
    required this.createdAt,
  });

  // Creates a Favorite instance from JSON data (for API responses)
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      itemId: json['itemId'] as String,
      userId: json['userId'] as String,
      createdAt: _parseDateTime(json['createdAt']), // Handle multiple date formats
    );
  }

  // Creates a Favorite instance from Firestore document
  factory Favorite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Favorite(
      itemId: data['itemId'] as String,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Convert Firestore timestamp
    );
  }

  // Converts to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(), // ISO string format
    };
  }

  // Converts to Firestore-compatible format
  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt), // Firestore timestamp format
    };
  }

  // Parses various date formats into DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate(); // Convert Firestore timestamp
    } else if (value is String) {
      return DateTime.parse(value); // Parse ISO string
    } else if (value is DateTime) {
      return value; // Already DateTime
    }
    throw ArgumentError('Invalid date format');
  }

  @override
  String toString() => 'Favorite(itemId: $itemId, userId: $userId)';

  // Equality comparison based on itemId and userId
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Favorite &&
              runtimeType == other.runtimeType &&
              itemId == other.itemId &&
              userId == other.userId;

  // Hash code for use in collections
  @override
  int get hashCode => itemId.hashCode ^ userId.hashCode;
}
