// favorite.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum FavoriteType {
  furnitureItem,
  design,
  project,
}

class Favorite {
  final String id;
  final String userId;
  final String itemId;
  final FavoriteType type;
  final DateTime createdAt;
  final String? notes;

  Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.createdAt,
    this.notes,
  });

  factory Favorite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Favorite(
      id: doc.id,
      userId: data['userId'] as String,
      itemId: data['itemId'] as String,
      type: FavoriteType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => FavoriteType.furnitureItem,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  Favorite copyWith({
    String? id,
    String? userId,
    String? itemId,
    FavoriteType? type,
    DateTime? createdAt,
    String? notes,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods
  bool get isFurnitureItem => type == FavoriteType.furnitureItem;
  bool get isDesign => type == FavoriteType.design;
  bool get isProject => type == FavoriteType.project;
}