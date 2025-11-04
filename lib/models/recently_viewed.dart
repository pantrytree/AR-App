import 'package:cloud_firestore/cloud_firestore.dart';

class RecentlyViewed {
  final String itemId;
  final String userId;
  final DateTime viewedAt;
  final int viewCount;

  RecentlyViewed({
    required this.itemId,
    required this.userId,
    required this.viewedAt,
    this.viewCount = 1,
  });

  // From JSON (API response)
  factory RecentlyViewed.fromJson(Map<String, dynamic> json) {
    return RecentlyViewed(
      itemId: json['itemId'] as String,
      userId: json['userId'] as String,
      viewedAt: _parseDateTime(json['viewedAt']),
      viewCount: json['viewCount'] as int? ?? 1,
    );
  }

  // From Firestore DocumentSnapshot
  factory RecentlyViewed.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecentlyViewed(
      itemId: data['itemId'] as String,
      userId: data['userId'] as String,
      viewedAt: (data['viewedAt'] as Timestamp).toDate(),
      viewCount: data['viewCount'] as int? ?? 1,
    );
  }

  // From Firestore Map
  factory RecentlyViewed.fromFirestoreMap(Map<String, dynamic> data) {
    return RecentlyViewed(
      itemId: data['itemId'] as String,
      userId: data['userId'] as String,
      viewedAt: (data['viewedAt'] as Timestamp).toDate(),
      viewCount: data['viewCount'] as int? ?? 1,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'userId': userId,
      'viewedAt': viewedAt.toIso8601String(),
      'viewCount': viewCount,
    };
  }

  // To Firestore (for Firestore writes)
  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'userId': userId,
      'viewedAt': Timestamp.fromDate(viewedAt),
      'viewCount': viewCount,
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

  RecentlyViewed copyWith({
    String? itemId,
    String? userId,
    DateTime? viewedAt,
    int? viewCount,
  }) {
    return RecentlyViewed(
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      viewedAt: viewedAt ?? this.viewedAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  String toString() => 'RecentlyViewed(itemId: $itemId, viewedAt: $viewedAt)';
}