import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';


/// using a local JSON file (`assets/help_data.json`) as data source.
/// This allows full frontend functionality without requiring backend integration.

class HelpPageViewModel extends ChangeNotifier {
  // Search query entered by the user
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Full list of help items loaded from JSON
  // Each item structure: {id, title, type, content}
  List<Map<String, dynamic>> _helpItems = [];

  // Filtered list shown in the UI based on search or selected type
  List<Map<String, dynamic>> _filteredHelpItems = [];
  List<Map<String, dynamic>> get filteredHelpItems => _filteredHelpItems;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Expansion state for each help item (used for accordion display)
  final Map<int, bool> _expansionStates = {};
  bool getExpansionState(int id) => _expansionStates[id] ?? false;

  /// Toggle the expanded or collapsed state for a help topic
  void toggleExpansion(int id) {
    _expansionStates[id] = !(_expansionStates[id] ?? false);
    notifyListeners();
  }

  /// Loads help data from a local JSON file (assets/help_data.json)
  /// This simulates how data would be fetched from a backend API later.
  Future<void> loadHelpData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load and decode local JSON data
      final String jsonString = await rootBundle.loadString('assets/help_data.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);

      // Convert to list of maps
      _helpItems = jsonResponse.map((item) => Map<String, dynamic>.from(item)).toList();

      // Initialize filtered list and default expansion states
      _filteredHelpItems = List.from(_helpItems);
      for (var item in _helpItems) {
        _expansionStates[item['id'] as int] = false;
      }

    } catch (e) {
      _errorMessage = 'Failed to load help content. Please try again.';
      debugPrint('Error loading help data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the search query and filters visible help items
  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterHelpItems();
    notifyListeners();
  }

  /// Filters help topics based on the current search query
  /// Matches are found if the query appears in either the title or content.
  void _filterHelpItems() {
    if (_searchQuery.isEmpty) {
      _filteredHelpItems = List.from(_helpItems);
    } else {
      _filteredHelpItems = _helpItems
          .where((item) =>
      item['title']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          (item['content'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  /// Called when the user taps the "Guides" card.
  /// TODO(shae): Replace with navigation logic or content filter.
  void onTapGuides() {
    debugPrint('Navigating to Guides...');
    // Example future logic:
    // _filteredHelpItems = _helpItems.where((item) => item['type'] == 'guide').toList();
    // notifyListeners();
  }

  /// Called when the user taps the "FAQ" card.
  /// TODO(shae): Replace with navigation logic or content filter.
  void onTapFAQ() {
    debugPrint('Navigating to FAQ...');
    // Example future logic:
    // _filteredHelpItems = _helpItems.where((item) => item['type'] == 'faq').toList();
    // notifyListeners();
  }
}
