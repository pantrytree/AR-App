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

class GuidesPageViewModel extends ChangeNotifier {
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

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filteredGuides = _allGuides.where((g) {
      return g.title.toLowerCase().contains(_searchQuery) ||
          g.description.toLowerCase().contains(_searchQuery);
    }).toList();
    notifyListeners();
  }

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
        return Icons.help_outline;
    }
  }

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
        return null;
    }
  }
}
