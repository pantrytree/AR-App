// design_object.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DesignObject {
  final String id;
  final String designId;
  final String userId;
  final String furnitureItemId;

  // Spatial properties
  final Map<String, dynamic> position; // {x, y, z}
  final Map<String, dynamic> rotation; // {x, y, z} in degrees
  final Map<String, dynamic>? scale; // {x, y, z}
  final String? selectedColor;
  final String? screenshotUrl;
  final String? arSessionId;
  final Map<String, dynamic>? arSessionData;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  DesignObject({
    required this.id,
    required this.designId,
    required this.userId,
    required this.furnitureItemId,
    required this.position,
    required this.rotation,
    this.scale,
    this.selectedColor,
    this.screenshotUrl,
    this.arSessionId,
    this.arSessionData,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

 
  // Creates a DesignObject instance from a Firestore document snapshot
  // Handles type conversion for spatial data and provides null safety
  factory DesignObject.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DesignObject(
      id: doc.id,
      designId: data['designId'] as String,
      userId: data['userId'] as String,
      furnitureItemId: data['furnitureItemId'] as String,
      // Convert position map with type safety 
      position: Map<String, dynamic>.from(data['position'] as Map),
      // Convert rotation map with type safety 
      rotation: Map<String, dynamic>.from(data['rotation'] as Map),
      // Convert scale map if present 
      scale: data['scale'] != null
          ? Map<String, dynamic>.from(data['scale'] as Map)
          : null,
      selectedColor: data['selectedColor'] as String?,
      screenshotUrl: data['screenshotUrl'] as String?,
      arSessionId: data['arSessionId'] as String?,
      // Convert AR session data map if present
      arSessionData: data['arSessionData'] != null
          ? Map<String, dynamic>.from(data['arSessionData'] as Map)
          : null,
      // Convert Firestore Timestamps to DateTime objects
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      // Convert metadata map if present
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'] as Map)
          : null,
    );
  }

  // Converts the DesignObject instance to a Map for Firestore storage
  // Handles DateTime to Timestamp conversion and maintains spatial data structure
  Map<String, dynamic> toFirestore() {
    return {
      'designId': designId,
      'userId': userId,
      'furnitureItemId': furnitureItemId,
      'position': position,
      'rotation': rotation,
      'scale': scale,
      'selectedColor': selectedColor,
      'screenshotUrl': screenshotUrl,
      'arSessionId': arSessionId,
      'arSessionData': arSessionData,
      // Convert DateTime to Firestore Timestamp for storage
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
    };
  }

  // Creates a new DesignObject instance with updated fields
  // Maintains immutability while allowing partial updates for spatial editing
  DesignObject copyWith({
    String? id,
    String? designId,
    String? userId,
    String? furnitureItemId,
    Map<String, dynamic>? position,
    Map<String, dynamic>? rotation,
    Map<String, dynamic>? scale,
    String? selectedColor,
    String? screenshotUrl,
    String? arSessionId,
    Map<String, dynamic>? arSessionData,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return DesignObject(
      id: id ?? this.id,
      designId: designId ?? this.designId,
      userId: userId ?? this.userId,
      furnitureItemId: furnitureItemId ?? this.furnitureItemId,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      selectedColor: selectedColor ?? this.selectedColor,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      arSessionId: arSessionId ?? this.arSessionId,
      arSessionData: arSessionData ?? this.arSessionData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Returns true if this object was created during an AR session
  bool get isFromArSession => arSessionId != null;
  
  // Helper to create from AR session
  factory DesignObject.fromArSession({
    required String id,
    required String designId,
    required String userId,
    required String furnitureItemId,
    required Map<String, dynamic> position,
    required Map<String, dynamic> rotation,
    required String arSessionId,
    Map<String, dynamic>? scale,
    String? selectedColor,
    String? screenshotUrl,
    Map<String, dynamic>? arSessionData,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return DesignObject(
      id: id,
      designId: designId,
      userId: userId,
      furnitureItemId: furnitureItemId,
      position: position,
      rotation: rotation,
      scale: scale,
      selectedColor: selectedColor,
      screenshotUrl: screenshotUrl,
      arSessionId: arSessionId,
      arSessionData: arSessionData,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }
}
