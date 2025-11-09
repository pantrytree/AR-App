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

  // Creates a Favorite instance from a Firestore document snapshot
  // Handles enum conversion from string and provides default values
  factory Favorite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Favorite(
      id: doc.id,
      userId: data['userId'] as String,
      itemId: data['itemId'] as String,
      // Convert string from Firestore to FavoriteType enum
      // Default to furnitureItem if type string doesn't match any enum value
      type: FavoriteType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => FavoriteType.furnitureItem,
      ),
      // Convert Firestore Timestamp to DateTime
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }

  // Converts the Favorite instance to a Map for Firestore storage
  // Stores enum values as their string names for readability
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'itemId': itemId,
      'type': type.name,  // Store enum as string
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  // Creates a new Favorite instance with updated fields
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

  // Helper methods for type checking 

  // Returns true if this favorite is for a furniture item
  bool get isFurnitureItem => type == FavoriteType.furnitureItem;

  // Returns true if this favorite is for a design
  bool get isDesign => type == FavoriteType.design;

  // Returns true if this favorite is for a project
  bool get isProject => type == FavoriteType.project;
}
