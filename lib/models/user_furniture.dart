import 'furniture_item.dart';

class UserFurniture {
  final String id;
  final String userId;
  final String roomId;
  final String furnitureId;
  final FurnitureItem? furnitureItem;
  final String? customName;
  final Map<String, dynamic> position; // {x, y, z}
  final Map<String, dynamic> rotation; // {x, y, z}
  final Map<String, dynamic> scale; // {x, y, z}
  final String? colorVariant;
  final bool isCustom;
  final String? customModelUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserFurniture({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.furnitureId,
    this.furnitureItem,
    this.customName,
    this.position = const {'x': 0, 'y': 0, 'z': 0},
    this.rotation = const {'x': 0, 'y': 0, 'z': 0},
    this.scale = const {'x': 1, 'y': 1, 'z': 1},
    this.colorVariant,
    this.isCustom = false,
    this.customModelUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserFurniture.fromJson(Map<String, dynamic> json) {
    return UserFurniture(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      roomId: json['room_id'].toString(),
      furnitureId: json['furniture_id'].toString(),
      furnitureItem: json['furniture_item'] != null
          ? FurnitureItem.fromJson(json['furniture_item'] as Map<String, dynamic>)
          : null,
      customName: json['custom_name'] as String?,
      position: json['position'] as Map<String, dynamic>? ?? {'x': 0, 'y': 0, 'z': 0},
      rotation: json['rotation'] as Map<String, dynamic>? ?? {'x': 0, 'y': 0, 'z': 0},
      scale: json['scale'] as Map<String, dynamic>? ?? {'x': 1, 'y': 1, 'z': 1},
      colorVariant: json['color_variant'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
      customModelUrl: json['custom_model_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': roomId,
      'furniture_id': furnitureId,
      'furniture_item': furnitureItem?.toJson(),
      'custom_name': customName,
      'position': position,
      'rotation': rotation,
      'scale': scale,
      'color_variant': colorVariant,
      'is_custom': isCustom,
      'custom_model_url': customModelUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}