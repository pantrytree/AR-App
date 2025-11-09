import 'package:flutter/material.dart';
import '../../../views/pages/guide_getting_started.dart';
import '../../../views/pages/guides_design_tools.dart';
import '../../../views/pages/guides_sharing_page.dart';
import '../../../views/pages/guides_media_sharing_page.dart';

class Guide {
  final String iconString;  
  final String title;       
  final String description; 

  Guide({
    required this.iconString,
    required this.title,
    required this.description,
  });
}

// ViewModel for managing guides page state and navigation
// Handles guide filtering, search, and page routing
class GuidesPageViewModel extends ChangeNotifier {
  // Predefined list of available help guides
  final List<Guide> _allGuides = [
    Guide(
      iconString: 'Icons.book',
      title: 'Getting Started Guide',
      description: 'Learn to set up your account and navigate the app.',
    ),
    Guide(
      iconString: 'Icons.edit',
      title: 'Design Tools Guide',
      description: 'Master the app\'s features to create custom projects.',
    ),
    Guide(
      iconString: 'Icons.share',
      title: 'Sharing & Collaboration Guide',
      description: 'Share projects and work with others.',
    ),
    Guide(
      iconString: 'Icons.file_upload',
      title: 'Importing Media Guide',
      description: 'Learn how to import and manage your media files.',
    ),
  ];

  List<Guide> _filteredGuides = []; 
  String _searchQuery = '';         

  GuidesPageViewModel() {
    _filteredGuides = List.from(_allGuides); 
  }

  List<Guide> get guides => _filteredGuides; 

  // Filters guides based on search query in title or description
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filteredGuides = _allGuides.where((g) {
      return g.title.toLowerCase().contains(_searchQuery) ||
          g.description.toLowerCase().contains(_searchQuery);
    }).toList();
    notifyListeners(); // Update UI with filtered results
  }

  // Converts icon string to actual Material icon
  IconData parseIcon(String iconString) {
    switch (iconString) {
      case 'Icons.book':
        return Icons.book;
      case 'Icons.edit':
        return Icons.edit;
      case 'Icons.share':
        return Icons.share;
      case 'Icons.file_upload':
        return Icons.file_upload;
      default:
        return Icons.help_outline; // Fallback icon
    }
  }

  // Returns the corresponding page widget for a guide title
  Widget? getPageForGuide(String title) {
    switch (title) {
      case 'Getting Started Guide':
        return const GuideGettingStartedPage();
      case 'Design Tools Guide':
        return const GuideDesignToolsPage();
      case 'Sharing & Collaboration Guide':
        return const GuideSharingPage();
      case 'Importing Media Guide':
        return const GuideImportingMediaPage();
      default:
        return null; // No page found for guide
    }
  }
}
