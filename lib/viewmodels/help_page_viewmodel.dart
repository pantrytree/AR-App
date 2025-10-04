import 'package:flutter/foundation.dart';

class HelpPageViewModel extends ChangeNotifier {

  String _searchQuery = '';
  String get searchQuery => _searchQuery;


  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }


  List<dynamic> _helpItems = [];
  List<dynamic> get helpItems => _helpItems;


  bool _isLoading = false;
  bool get isLoading => _isLoading;


  String? _errorMessage;
  String? get errorMessage => _errorMessage;


  bool _isGeneralDescriptionExpanded = false;
  bool _isImportGuidesExpanded = false;
  bool _isAdditionalServicesExpanded = false;


  bool get isGeneralDescriptionExpanded => _isGeneralDescriptionExpanded;
  bool get isImportGuidesExpanded => _isImportGuidesExpanded;
  bool get isAdditionalServicesExpanded => _isAdditionalServicesExpanded;


  Future<void> loadHelpData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _helpItems = [
        {'id': 1, 'title': 'General Description', 'type': 'info'},
        {'id': 2, 'title': 'Import Guides', 'type': 'guide'},
        {'id': 3, 'title': 'Additional Services', 'type': 'info'},
        {'id': 4, 'title': 'FAQ 1: How do I reset my password?', 'type': 'faq'},
        {'id': 5, 'title': 'FAQ 2: How do I contact support?', 'type': 'faq'},
      ];
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load help content. Please try again.';
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  void onTapGuides() {
    print('ViewModel: User tapped Guides');
  }


  void onTapFAQ() {
    print('ViewModel: User tapped FAQ');
  }


  void toggleGeneralDescription() {
    _isGeneralDescriptionExpanded = !_isGeneralDescriptionExpanded;
    notifyListeners();
  }

  void toggleImportGuides() {
    _isImportGuidesExpanded = !_isImportGuidesExpanded;
    notifyListeners();
  }

  void toggleAdditionalServices() {
    _isAdditionalServicesExpanded = !_isAdditionalServicesExpanded;
    notifyListeners();
  }
}