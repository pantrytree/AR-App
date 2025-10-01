// design_object.dart
import 'ar_object.dart';

class DesignObject {
  final String id;
  final ARObject object;
  final double posX;
  final double posY;
  final double posZ;
  final double rotation;

  DesignObject({
    required this.id,
    required this.object,
    required this.posX,
    required this.posY,
    required this.posZ,
    required this.rotation,
  });
}
