class FurnitureService {
  //Backend team will implement real API call
  Future<List<Map<String, dynamic>>> getRecentlyUsedItems() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API delay
    return [
      {"title": "Beige Couch", "id": "1"}, // Placeholder data
      {"title": "Pink Bed", "id": "2"}, // Placeholder data
      {"title": "Silver Lamp", "id": "3"}, // Placeholder data
    ];
  }

  //Backend team will implement real API call
  Future<List<Map<String, dynamic>>> getRoomCategories() async {
    return [
      {"title": "Living Room", "id": "living"}, // Placeholder data
      {"title": "Bedroom", "id": "bedroom"}, // Placeholder data
      {"title": "Kitchen", "id": "kitchen"}, // Placeholder data
      {"title": "Office", "id": "office"}, // Placeholder data
    ];
  }
}