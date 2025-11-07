import 'package:cloud_firestore/cloud_firestore.dart';

class Favorite {
  final String itemId;
  final String userId;
  final DateTime createdAt;

  Favorite({
    required this.itemId,
    required this.userId,
    required this.createdAt,
  });

  //From JSON (API response)
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      itemId: json['itemId'] as String,
      userId: json['userId'] as String,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  //From Firestore DocumentSnapshot
  factory Favorite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Favorite(
      itemId: data['itemId'] as String,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    }
    throw ArgumentError('Invalid date format');
  }

  @override
  String toString() => 'Favorite(itemId: $itemId, userId: $userId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Favorite &&
              runtimeType == other.runtimeType &&
              itemId == other.itemId &&
              userId == other.userId;

  @override
  int get hashCode => itemId.hashCode ^ userId.hashCode;
}
