import 'package:flutter/material.dart';

class FilterOption {
  final String value;
  final String label;

  FilterOption(this.value, this.label);
}

class FilterOptions {
  // Room filter options
  static final List<FilterOption> roomOptions = [
    FilterOption('all', 'All Rooms'),
    FilterOption('living room', 'Living Room'),
    FilterOption('bedroom', 'Bedroom'),
    FilterOption('office', 'Office'),
    FilterOption('dining', 'Dining'),
    FilterOption('kitchen', 'Kitchen'),
    FilterOption('bathroom', 'Bathroom'),
  ];

  // Type filter options
  static final List<FilterOption> typeOptions = [
    FilterOption('all', 'All Types'),
    FilterOption('bed', 'Beds'),
    FilterOption('sofa', 'Sofas'),
    FilterOption('chair', 'Chairs'),
    FilterOption('table', 'Tables'),
    FilterOption('lamp', 'Lamps'),
    FilterOption('wardrobe', 'Wardrobes'),
    FilterOption('desk', 'Desks'),
    FilterOption('cabinet', 'Cabinets'),
  ];

  // Style filter options
  static final List<FilterOption> styleOptions = [
    FilterOption('all', 'All Styles'),
    FilterOption('modern', 'Modern'),
    FilterOption('traditional', 'Traditional'),
    FilterOption('minimalist', 'Minimalist'),
    FilterOption('industrial', 'Industrial'),
    FilterOption('contemporary', 'Contemporary'),
    FilterOption('rustic', 'Rustic'),
  ];

  // Color filter options
  static final List<FilterOption> colorOptions = [
    FilterOption('all', 'All Colors'),
    FilterOption('pink', 'Pink'),
    FilterOption('white', 'White'),
    FilterOption('grey', 'Grey'),
    FilterOption('black', 'Black'),
    FilterOption('brown', 'Brown'),
    FilterOption('silver', 'Silver'),
    FilterOption('beige', 'Beige'),
    FilterOption('blue', 'Blue'),
    FilterOption('green', 'Green'),
  ];

  // Category filter options for Home and Catalogue pages
  static final List<FilterOption> categoryOptions = [
    FilterOption('all', 'All'),
    FilterOption('bedroom', 'Bedroom'),
    FilterOption('living room', 'Living Room'),
    FilterOption('office', 'Office'),
    FilterOption('dining', 'Dining'),
    FilterOption('kitchen', 'Kitchen'),
    FilterOption('bathroom', 'Bathroom'),
  ];

  // Room card options for Home page
  static final List<Map<String, dynamic>> roomCardOptions = [
    {
      'name': 'Living Room',
      'icon': Icons.weekend,
      'itemCount': 24,
      'roomType': 'living room',
      'filterOption': FilterOption('living room', 'Living Room'),
    },
    {
      'name': 'Bedroom',
      'icon': Icons.bed,
      'itemCount': 18,
      'roomType': 'bedroom',
      'filterOption': FilterOption('bedroom', 'Bedroom'),
    },
    {
      'name': 'Office',
      'icon': Icons.work,
      'itemCount': 15,
      'roomType': 'office',
      'filterOption': FilterOption('office', 'Office'),
    },
    {
      'name': 'Dining Room',
      'icon': Icons.dining,
      'itemCount': 12,
      'roomType': 'dining',
      'filterOption': FilterOption('dining', 'Dining'),
    },
    {
      'name': 'Kitchen',
      'icon': Icons.kitchen,
      'itemCount': 10,
      'roomType': 'kitchen',
      'filterOption': FilterOption('kitchen', 'Kitchen'),
    },
    {
      'name': 'Bathroom',
      'icon': Icons.bathtub,
      'itemCount': 8,
      'roomType': 'bathroom',
      'filterOption': FilterOption('bathroom', 'Bathroom'),
    },
  ];

  // Recently used items
  static final List<Map<String, String>> recentItems = [
    {'id': '1', 'name': 'Pink Bed', 'catalogueName': 'Pink Queen Bed'},
    {'id': '2', 'name': 'Silver Lamp', 'catalogueName': 'Silver Modern Lamp'},
    {'id': '3', 'name': 'Wooden Desk', 'catalogueName': 'Wooden Modern Desk'},
    {'id': '4', 'name': 'Grey Couch', 'catalogueName': 'Grey Modern Sofa'},
  ];

  // Helper method to find FilterOption by value
  static FilterOption getOptionByValue(List<FilterOption> options, String value) {
    return options.firstWhere(
          (option) => option.value == value,
      orElse: () => options.firstWhere((option) => option.value == 'all'),
    );
  }

  // Helper method to get room icon
  static IconData getRoomIcon(String roomType) {
    switch (roomType) {
      case 'living room':
        return Icons.weekend;
      case 'bedroom':
        return Icons.bed;
      case 'office':
        return Icons.work;
      case 'dining':
        return Icons.dining;
      case 'kitchen':
        return Icons.kitchen;
      case 'bathroom':
        return Icons.bathtub;
      default:
        return Icons.room;
    }
  }
}