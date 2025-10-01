// collaboration.dart
import 'package:roomanties/models/user.dart';
import 'design.dart';

class Collaboration {
  final String id;
  final Design design;
  final User designer;
  final User client;
  final String status;
  final DateTime createdAt;

  Collaboration({
    required this.id,
    required this.design,
    required this.designer,
    required this.client,
    required this.status,
    required this.createdAt,
  });
}
