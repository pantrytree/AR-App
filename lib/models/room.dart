import 'package:flutter/material.dart';

class RoomInfo {
  final String name;
  final int itemCount;
  final IconData icon;
  final String description;

  RoomInfo({
    required this.name,
    required this.itemCount,
    required this.icon,
    required this.description,
  });

  // From Map (from RoomService)
  factory RoomInfo.fromMap(Map<String, dynamic> map) {
    return RoomInfo(
      name: map['name'] as String,
      itemCount: map['itemCount'] as int,
      icon: _parseIconData(map['icon'] as String),
      description: map['description'] as String,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'itemCount': itemCount,
      'icon': _iconDataToString(icon),
      'description': description,
    };
  }

  // Helper methods for icon conversion
  static IconData _parseIconData(String iconString) {
    final iconMap = {
      'weekend': Icons.weekend,
      'bed': Icons.bed,
      'work': Icons.work,
      'kitchen': Icons.kitchen,
      'dining': Icons.dining,
      'bathtub': Icons.bathtub,
      'chair': Icons.chair,
      'table_restaurant': Icons.table_restaurant,
      'lightbulb': Icons.lightbulb,
      'weekend_outlined': Icons.weekend_outlined,
    };
    return iconMap[iconString] ?? Icons.widgets;
  }

  static String _iconDataToString(IconData icon) {
    final iconMap = {
      Icons.weekend: 'weekend',
      Icons.bed: 'bed',
      Icons.work: 'work',
      Icons.kitchen: 'kitchen',
      Icons.dining: 'dining',
      Icons.bathtub: 'bathtub',
      Icons.chair: 'chair',
      Icons.table_restaurant: 'table_restaurant',
      Icons.lightbulb: 'lightbulb',
      Icons.weekend_outlined: 'weekend_outlined',
    };
    return iconMap[icon] ?? 'widgets';
  }

  RoomInfo copyWith({
    String? name,
    int? itemCount,
    IconData? icon,
    String? description,
  }) {
    return RoomInfo(
      name: name ?? this.name,
      itemCount: itemCount ?? this.itemCount,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'RoomInfo(name: $name, items: $itemCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RoomInfo && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}