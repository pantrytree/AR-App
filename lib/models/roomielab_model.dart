class RoomieLabDesign {
  final String id;
  final String name;
  final String imagePath;
  final DateTime createdAt;
  final List<PlacedFurniture> placedFurniture;
  final String? roomType;
  final String category;

  RoomieLabDesign({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.createdAt,
    required this.placedFurniture,
    this.roomType,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'placedFurniture': placedFurniture.map((f) => f.toJson()).toList(),
      'roomType': roomType,
      'category': category, // Add this line
    };
  }

  factory RoomieLabDesign.fromJson(Map<String, dynamic> json) {
    return RoomieLabDesign(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      placedFurniture: List<PlacedFurniture>.from(
          json['placedFurniture'].map((f) => PlacedFurniture.fromJson(f))),
      roomType: json['roomType'],
      category: json['category'] ?? 'Uncategorized', // Add this line with fallback
    );
  }
}

class PlacedFurniture {
  final String furnitureId;
  final String furnitureName;
  final String furnitureType;
  final String imageUrl;
  final Position position;
  final double rotation;
  final double scale;

  PlacedFurniture({
    required this.furnitureId,
    required this.furnitureName,
    required this.furnitureType,
    required this.imageUrl,
    required this.position,
    this.rotation = 0,
    this.scale = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'furnitureId': furnitureId,
      'furnitureName': furnitureName,
      'furnitureType': furnitureType,
      'imageUrl': imageUrl,
      'position': position.toJson(),
      'rotation': rotation,
      'scale': scale,
    };
  }

  factory PlacedFurniture.fromJson(Map<String, dynamic> json) {
    return PlacedFurniture(
      furnitureId: json['furnitureId'],
      furnitureName: json['furnitureName'],
      furnitureType: json['furnitureType'],
      imageUrl: json['imageUrl'],
      position: Position.fromJson(json['position']),
      rotation: json['rotation'] ?? 0,
      scale: json['scale'] ?? 1.0,
    );
  }
}

class Position {
  final double x;
  final double y;
  final double z;

  Position({required this.x, required this.y, required this.z});

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: json['x'] ?? 0,
      y: json['y'] ?? 0,
      z: json['z'] ?? 0,
    );
  }
}