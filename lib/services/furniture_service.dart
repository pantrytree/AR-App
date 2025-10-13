class FurnitureService {
  Future<List<Map<String, String>>> getRecentlyUsedItems() async {
    // TODO: Backend - Implement actual furniture service
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

    return [
      {"title": "Beige Couch", "id": "1"},
      {"title": "Pink Bed", "id": "2"},
      {"title": "Silver Lamp", "id": "3"},
      {"title": "Wooden Table", "id": "4"},
    ];
  }

  Future<List<Map<String, String>>> getRoomCategories() async {
    // TODO: Backend - Implement actual furniture service
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

    return [
      {"title": "Living Room", "id": "living"},
      {"title": "Bedroom", "id": "bedroom"},
      {"title": "Kitchen", "id": "kitchen"},
      {"title": "Office", "id": "office"},
      {"title": "Dining Room", "id": "dining"},
      {"title": "Bathroom", "id": "bathroom"},
    ];
  }
}