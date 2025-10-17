import 'dart:math' as Math;

class DesignObject {
  final String itemId;
  final Position position;
  final Rotation rotation;
  final Scale scale;

  DesignObject({
    required this.itemId,
    required this.position,
    required this.rotation,
    required this.scale,
  });

  // From JSON (API response)
  factory DesignObject.fromJson(Map<String, dynamic> json) {
    return DesignObject(
      itemId: json['itemId'] as String,
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      rotation: Rotation.fromJson(json['rotation'] as Map<String, dynamic>),
      scale: Scale.fromJson(json['scale'] as Map<String, dynamic>),
    );
  }

  // From Firestore Map (same as fromJson but explicit name)
  factory DesignObject.fromMap(Map<String, dynamic> map) {
    return DesignObject(
      itemId: map['itemId'] as String,
      position: Position.fromJson(map['position'] as Map<String, dynamic>),
      rotation: Rotation.fromJson(map['rotation'] as Map<String, dynamic>),
      scale: Scale.fromJson(map['scale'] as Map<String, dynamic>),
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'position': position.toJson(),
      'rotation': rotation.toJson(),
      'scale': scale.toJson(),
    };
  }

  // To Map (for Firestore - same as toJson)
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'position': position.toJson(),
      'rotation': rotation.toJson(),
      'scale': scale.toJson(),
    };
  }

  DesignObject copyWith({
    String? itemId,
    Position? position,
    Rotation? rotation,
    Scale? scale,
  }) {
    return DesignObject(
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
    );
  }

  @override
  String toString() => 'DesignObject(itemId: $itemId, position: $position, rotation: $rotation, scale: $scale)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DesignObject &&
              runtimeType == other.runtimeType &&
              itemId == other.itemId &&
              position == other.position &&
              rotation == other.rotation &&
              scale == other.scale;

  @override
  int get hashCode =>
      itemId.hashCode ^
      position.hashCode ^
      rotation.hashCode ^
      scale.hashCode;

  void operator [](String other) {}
}
// POSITION CLASS

class Position {
  final double x;
  final double y;
  final double z;

  Position({required this.x, required this.y, required this.z});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  Position copyWith({double? x, double? y, double? z}) {
    return Position(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  // Helper methods for AR manipulation
  Position translate(double dx, double dy, double dz) {
    return Position(
      x: x + dx,
      y: y + dy,
      z: z + dz,
    );
  }

  double distanceTo(Position other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return Math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  @override
  String toString() => 'Position(x: $x, y: $y, z: $z)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Position &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y &&
              z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

// ROTATION CLASS

class Rotation {
  final double x;
  final double y;
  final double z;

  Rotation({required this.x, required this.y, required this.z});

  factory Rotation.fromJson(Map<String, dynamic> json) {
    return Rotation(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  Rotation copyWith({double? x, double? y, double? z}) {
    return Rotation(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  // Helper methods for AR manipulation
  Rotation rotate(double dx, double dy, double dz) {
    return Rotation(
      x: _normalizeAngle(x + dx),
      y: _normalizeAngle(y + dy),
      z: _normalizeAngle(z + dz),
    );
  }

  // Normalize angle to 0-360 degrees
  double _normalizeAngle(double angle) {
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    return angle;
  }

  // Convert to radians
  Rotation toRadians() {
    return Rotation(
      x: x * Math.pi / 180,
      y: y * Math.pi / 180,
      z: z * Math.pi / 180,
    );
  }

  // Convert from radians
  factory Rotation.fromRadians(double x, double y, double z) {
    return Rotation(
      x: x * 180 / Math.pi,
      y: y * 180 / Math.pi,
      z: z * 180 / Math.pi,
    );
  }

  @override
  String toString() => 'Rotation(x: $x°, y: $y°, z: $z°)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Rotation &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y &&
              z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

// SCALE CLASS

class Scale {
  final double x;
  final double y;
  final double z;

  Scale({required this.x, required this.y, required this.z});

  // Uniform scale constructor
  Scale.uniform(double scale)
      : x = scale,
        y = scale,
        z = scale;

  // Default scale (1:1:1)
  factory Scale.identity() => Scale(x: 1.0, y: 1.0, z: 1.0);

  factory Scale.fromJson(Map<String, dynamic> json) {
    return Scale(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  Scale copyWith({double? x, double? y, double? z}) {
    return Scale(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  // Helper methods for AR manipulation
  Scale scaleBy(double factor) {
    return Scale(
      x: x * factor,
      y: y * factor,
      z: z * factor,
    );
  }

  Scale scaleByAxis(double xFactor, double yFactor, double zFactor) {
    return Scale(
      x: x * xFactor,
      y: y * yFactor,
      z: z * zFactor,
    );
  }

  // Check if scale is uniform
  bool get isUniform => x == y && y == z;

  // Get average scale
  double get average => (x + y + z) / 3;

  @override
  String toString() => 'Scale(x: $x, y: $y, z: $z)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Scale &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y &&
              z == other.z;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

// HELPER CLASS: Transform (combines Position, Rotation, Scale)

class Transform {
  final Position position;
  final Rotation rotation;
  final Scale scale;

  Transform({
    required this.position,
    required this.rotation,
    required this.scale,
  });

  // Default/Identity transform
  factory Transform.identity() {
    return Transform(
      position: Position(x: 0, y: 0, z: 0),
      rotation: Rotation(x: 0, y: 0, z: 0),
      scale: Scale.identity(),
    );
  }

  factory Transform.fromJson(Map<String, dynamic> json) {
    return Transform(
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      rotation: Rotation.fromJson(json['rotation'] as Map<String, dynamic>),
      scale: Scale.fromJson(json['scale'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position.toJson(),
      'rotation': rotation.toJson(),
      'scale': scale.toJson(),
    };
  }

  Transform copyWith({
    Position? position,
    Rotation? rotation,
    Scale? scale,
  }) {
    return Transform(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
    );
  }

  @override
  String toString() => 'Transform(position: $position, rotation: $rotation, scale: $scale)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Transform &&
              runtimeType == other.runtimeType &&
              position == other.position &&
              rotation == other.rotation &&
              scale == other.scale;

  @override
  int get hashCode =>
      position.hashCode ^ rotation.hashCode ^ scale.hashCode;
}