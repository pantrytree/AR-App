// ar_object.dart
class ARObject {
  final String id;
  final String name;
  final String category;
  final String fileUrl;
  final DateTime createdAt;

  ARObject({
    required this.id,
    required this.name,
    required this.category,
    required this.fileUrl,
    required this.createdAt,
  });
}
