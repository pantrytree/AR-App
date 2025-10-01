// design.dart
import 'package:roomanties/models/user.dart';
import 'design_object.dart';

class Design {
  final String id;
  final String name;
  final User creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DesignObject> objects;

  Design({
    required this.id,
    required this.name,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.objects,
  });
}
