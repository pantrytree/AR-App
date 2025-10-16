import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/filter_options.dart';
import '/views/widgets/side_menu.dart';
import '/views/widgets/bottom_nav_bar.dart';
import '/viewmodels/home_viewmodel.dart';
import '/viewmodels/side_menu_viewmodel.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/utils/text_components.dart';
import '/views/pages/furniture_catalogue_page.dart';
import '/views/pages/all_rooms_page.dart';
import '/views/pages/my_likes_page.dart';
import '/views/pages/settings_page.dart';
import '/views/pages/help_page.dart';
import '/views/pages/about_page.dart';
import '/views/pages/roomielab_screen.dart';
import '../../models/furniture_model.dart';
import '../../services/furniture_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => SideMenuViewModel(userName: "Bulelwa")),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<HomeViewModel>(
            builder: (context, homeViewModel, child) {
              if (homeViewModel.navigateToRoute != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(
                    context,
                    homeViewModel.navigateToRoute!,
                    arguments: homeViewModel.navigationArguments,
                  ).then((_) => homeViewModel.clearNavigation());
                });
              }

              return Scaffold(
                backgroundColor: AppColors.getBackgroundColor(context),
                appBar: AppBar(
                  backgroundColor: AppColors.getAppBarBackground(context),
                  title: Text(
                    TextComponents.homePageTitle,
                    style: TextStyle(
                      color: AppColors.getAppBarForeground(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevation: 0,
                  actions: [],
                ),
                drawer: const SideMenu(),
                body: _buildBody(context, homeViewModel),
                bottomNavigationBar: _buildBottomNavigationBar(context, homeViewModel),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel homeViewModel) {
    if (homeViewModel.isLoading) {
      return _buildLoadingState(context);
    }

    if (homeViewModel.hasError) {
      return _buildErrorState(context, homeViewModel);
    }

    return _buildContent(context, homeViewModel);
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, HomeViewModel homeViewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.getPrimaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            TextComponents.loadingError,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeViewModel.errorMessage ?? TextComponents.unknownError,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => homeViewModel.refreshHomePage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimaryColor(context),
              foregroundColor: Colors.white,
            ),
            child: Text(TextComponents.retryButton),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeViewModel homeViewModel) {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(context, homeViewModel),
          Expanded(
            child: homeViewModel.isSearching
                ? _buildSearchResults(context, homeViewModel)
                : _buildHomeContent(context, homeViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeViewModel homeViewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextComponents.homeGreeting(homeViewModel.currentUser?['displayName'] ?? 'User'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TextComponents.homeWelcome,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 32),
            _buildRecentlyUsedSection(context, homeViewModel),
            const SizedBox(height: 32),
            _buildAllRoomsSection(context, homeViewModel),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeViewModel homeViewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.getTextFieldBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: homeViewModel.searchController,
          onChanged: (query) => homeViewModel.performSearch(query),
          decoration: InputDecoration(
            hintText: 'Search furniture, rooms, settings, help...',
            hintStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
            prefixIcon: Icon(Icons.search, color: AppColors.getSecondaryTextColor(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: homeViewModel.isSearching
                ? IconButton(
              icon: Icon(Icons.close, color: AppColors.getSecondaryTextColor(context)),
              onPressed: () => homeViewModel.clearSearch(),
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, HomeViewModel homeViewModel) {
    if (homeViewModel.searchQuery.isEmpty) {
      return _buildSearchSuggestions(context, homeViewModel);
    }

    if (homeViewModel.searchResults.isEmpty) {
      return _buildNoResults(context, homeViewModel);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: homeViewModel.searchResults.length,
      itemBuilder: (context, index) {
        final result = homeViewModel.searchResults[index];
        return _buildSearchResultItem(context, result, homeViewModel);
      },
    );
  }

  Widget _buildSearchSuggestions(BuildContext context, HomeViewModel homeViewModel) {
    final suggestions = [
      'Living Room Furniture',
      'Bedroom Sets',
      'Office Chairs',
      'Sofas',
      'Tables',
      'Settings',
      'Help',
      'My Likes',
      'AR Studio'
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () {
                  homeViewModel.searchController.text = suggestion;
                  homeViewModel.performSearch(suggestion);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.getPrimaryColor(context).withOpacity(0.3)),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, HomeViewModel homeViewModel) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for furniture, rooms, or settings',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(BuildContext context, SearchResult result, HomeViewModel homeViewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          result.icon,
          color: AppColors.getPrimaryColor(context),
        ),
        title: Text(
          result.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(result.subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () => _navigateToSearchResult(context, result),
      ),
    );
  }

  void _navigateToSearchResult(BuildContext context, SearchResult result) {
    switch (result.type) {
      case SearchResultType.furniture:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FurnitureCataloguePage(itemToShowDetails: result.title),
          ),
        );
        break;
      case SearchResultType.room:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FurnitureCataloguePage(initialRoom: result.data),
          ),
        );
        break;
      case SearchResultType.category:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FurnitureCataloguePage(initialType: result.data),
          ),
        );
        break;
      case SearchResultType.likes:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MyLikesPage(),
          ),
        );
        break;
      case SearchResultType.settings:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SettingsPage(),
          ),
        );
        break;
      case SearchResultType.help:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HelpPage(),
          ),
        );
        break;
      case SearchResultType.about:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AboutPage(),
          ),
        );
        break;
      case SearchResultType.ar:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RoomieLabScreen(),
          ),
        );
        break;
    }
  }

  Widget _buildRecentlyUsedSection(BuildContext context, HomeViewModel homeViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FurnitureCataloguePage(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TextComponents.recentlyUsedTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.getTextColor(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          TextComponents.recentlyUsedSubtitle,
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: FilterOptions.recentItems.length,
            itemBuilder: (context, index) {
              final item = FilterOptions.recentItems[index];
              return _buildRecentItemCard(context, homeViewModel, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllRoomsSection(BuildContext context, HomeViewModel homeViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AllRoomsPage(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TextComponents.allRoomsTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.getTextColor(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: FilterOptions.roomCardOptions.length,
            itemBuilder: (context, index) {
              final room = FilterOptions.roomCardOptions[index];
              return _buildRoomCard(context, homeViewModel, room);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItemCard(BuildContext context, HomeViewModel homeViewModel, Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        _navigateToFurnitureDetails(context, item);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getFurnitureIconForRecentItem(item['name']!),
                color: AppColors.getPrimaryColor(context),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['name']!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, HomeViewModel homeViewModel, Map<String, dynamic> room) {
    final filterOption = room['filterOption'] as FilterOption;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FurnitureCataloguePage(initialRoom: filterOption.value),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              room['icon'],
              size: 40,
              color: AppColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 8),
            Text(
              room['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, HomeViewModel homeViewModel) {
    return BottomNavigationBar(
      backgroundColor: AppColors.getAppBarBackground(context),
      selectedItemColor: AppColors.getPrimaryColor(context),
      unselectedItemColor: AppColors.getSecondaryTextColor(context),
      currentIndex: homeViewModel.selectedIndex,
      onTap: (index) => homeViewModel.onTabSelected(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Likes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'AR View',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Catalogue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _navigateToFurnitureDetails(BuildContext context, Map<String, String> item) {
    // Navigate to FurnitureCataloguePage with the specific item to show details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FurnitureCataloguePage(
          itemToShowDetails: item['name'],
        ),
      ),
    );
  }

  IconData _getFurnitureIconForRecentItem(String itemName) {
    // Find the matching furniture item and return its appropriate icon
    try {
      final furnitureItem = FurnitureService.allFurniture.firstWhere(
            (furniture) => furniture.name.toLowerCase().contains(itemName.toLowerCase()),
      );
      return _getFurnitureIcon(furnitureItem.furnitureType);
    } catch (e) {
      return Icons.chair; // Default icon
    }
  }

  IconData _getFurnitureIcon(String furnitureType) {
    switch (furnitureType.toLowerCase()) {
      case 'bed':
        return Icons.bed;
      case 'sofa':
        return Icons.weekend;
      case 'chair':
        return Icons.chair;
      case 'table':
        return Icons.table_restaurant;
      case 'lamp':
        return Icons.lightbulb;
      case 'wardrobe':
        return Icons.king_bed;
      default:
        return Icons.chair;
    }
  }
}