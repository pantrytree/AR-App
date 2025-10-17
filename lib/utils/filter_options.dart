import 'package:flutter/material.dart';

class FilterOption {
  final String value;
  final String label;

  FilterOption(this.value, this.label);
}

class FilterOptions {
  // Room filter options
  static final List<FilterOption> roomOptions = [
    FilterOption('All', 'All Rooms'),
    FilterOption('Living Room', 'Living Room'),
    FilterOption('Bedroom', 'Bedroom'),
    FilterOption('Office', 'Office'),
    FilterOption('Dining', 'Dining'),
    FilterOption('Kitchen', 'Kitchen'),
    FilterOption('Bathroom', 'Bathroom'),
  ];

  // Type filter options
  static final List<FilterOption> typeOptions = [
    FilterOption('All', 'All Types'),
    FilterOption('Bed', 'Beds'),
    FilterOption('Sofa', 'Sofas'),
    FilterOption('Chair', 'Chairs'),
    FilterOption('Table', 'Tables'),
    FilterOption('Lamp', 'Lamps'),
    FilterOption('Wardrobe', 'Wardrobes'),
    FilterOption('Desk', 'Desks'),
    FilterOption('Cabinet', 'Cabinets'),
  ];

  // Style filter options
  static final List<FilterOption> styleOptions = [
    FilterOption('All', 'All Styles'),
    FilterOption('Modern', 'Modern'),
    FilterOption('Traditional', 'Traditional'),
    FilterOption('Minimalist', 'Minimalist'),
    FilterOption('Industrial', 'Industrial'),
    FilterOption('Contemporary', 'Contemporary'),
    FilterOption('Rustic', 'Rustic'),
  ];

  // Color filter options
  static final List<FilterOption> colorOptions = [
    FilterOption('All', 'All Colors'),
    FilterOption('Pink', 'Pink'),
    FilterOption('White', 'White'),
    FilterOption('Grey', 'Grey'),
    FilterOption('Black', 'Black'),
    FilterOption('Brown', 'Brown'),
    FilterOption('Silver', 'Silver'),
    FilterOption('Beige', 'Beige'),
    FilterOption('Blue', 'Blue'),
    FilterOption('Green', 'Green'),
  ];

  // Category filter options for Home and Catalogue pages
  static final List<FilterOption> categoryOptions = [
    FilterOption('All', 'All'),
    FilterOption('Bedroom', 'Bedroom'),
    FilterOption('Living Room', 'Living Room'),
    FilterOption('Office', 'Office'),
    FilterOption('Dining Room', 'Dining'),
    FilterOption('Kitchen', 'Kitchen'),
    FilterOption('Bathroom', 'Bathroom'),
  ];

  // Room card options for Home page
  static final List<Map<String, dynamic>> roomCardOptions = [
    {
      'name': 'Living Room',
      'icon': Icons.weekend,
      'itemCount': 24,
      'roomType': 'Living Room',
      'filterOption': FilterOption('Living Room', 'Living Room'),
    },
    {
      'name': 'Bedroom',
      'icon': Icons.bed,
      'itemCount': 18,
      'roomType': 'Bedroom',
      'filterOption': FilterOption('Bedroom', 'Bedroom'),
    },
    {
      'name': 'Office',
      'icon': Icons.work,
      'itemCount': 15,
      'roomType': 'Office',
      'filterOption': FilterOption('Office', 'Office'),
    },
    {
      'name': 'Dining Room',
      'icon': Icons.dining,
      'itemCount': 12,
      'roomType': 'Dining Room',
      'filterOption': FilterOption('Dining Room', 'Dining Room'),
    },
    {
      'name': 'Kitchen',
      'icon': Icons.kitchen,
      'itemCount': 10,
      'roomType': 'Kitchen',
      'filterOption': FilterOption('Kitchen', 'Kitchen'),
    },
    {
      'name': 'Bathroom',
      'icon': Icons.bathtub,
      'itemCount': 8,
      'roomType': 'Bathroom',
      'filterOption': FilterOption('Bathroom', 'Bathroom'),
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
      orElse: () => options.firstWhere((option) => option.value == 'All'),
    );
  }

  // Helper method to get room icon
  static IconData getRoomIcon(String roomType) {
    switch (roomType) {
      case 'Living Room':
        return Icons.weekend;
      case 'Bedroom':
        return Icons.bed;
      case 'Office':
        return Icons.work;
      case 'Dining':
        return Icons.dining;
      case 'Kitchen':
        return Icons.kitchen;
      case 'Bathroom':
        return Icons.bathtub;
      default:
        return Icons.room;
    }
  }
}