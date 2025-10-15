import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/side_menu.dart';
import '../widgets/bottom_nav_bar.dart';
import '/viewmodels/home_viewmodel.dart';
import '../../../viewmodels/side_menu_viewmodel.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '../../../utils/text_components.dart';

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
              // Handle HomeViewModel navigation
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
                  actions: [
                    IconButton(
                      icon: Icon(
                          Icons.search,
                          color: AppColors.getAppBarForeground(context)
                      ),
                      onPressed: () => homeViewModel.onSearchTapped(),
                    ),
                  ],
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
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.getPrimaryColor(context),
      ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Greeting
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
            const SizedBox(height: 24),

            // Search Bar
            _buildSearchBar(context, homeViewModel),
            const SizedBox(height: 32),

            // Recently Used Section
            _buildRecentlyUsedSection(context, homeViewModel),
            const SizedBox(height: 32),

            // All Rooms Section
            _buildAllRoomsSection(context, homeViewModel),

            // Added an extra space at the bottom to ensure content doesn't get cut off
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeViewModel homeViewModel) {
    return GestureDetector(
      onTap: () => homeViewModel.onSearchTapped(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            Icon(
                Icons.search,
                color: AppColors.getSecondaryTextColor(context)
            ),
            const SizedBox(width: 12),
            Text(
              TextComponents.searchPlaceholder,
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyUsedSection(BuildContext context, HomeViewModel homeViewModel) {
    final List<Map<String, String>> recentItems = [
      {'id': '1', 'name': 'Pink Bed'},
      {'id': '2', 'name': 'Silver Lamp'},
      {'id': '3', 'name': 'Wooden Desk'},
      {'id': '4', 'name': 'Grey Couch'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextComponents.recentlyUsedTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
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

        // Recently Used Items as horizontal tabs
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentItems.length,
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return _buildRecentItemCard(context, homeViewModel, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllRoomsSection(BuildContext context, HomeViewModel homeViewModel) {
    final List<Map<String, String>> roomCategories = [
      {'id': '1', 'name': 'Living Room', 'type': 'living_room'},
      {'id': '2', 'name': 'Dining Room', 'type': 'dining_room'},
      {'id': '3', 'name': 'Office', 'type': 'office'},
      {'id': '4', 'name': 'Kitchen', 'type': 'kitchen'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Make the title clickable
        GestureDetector(
          onTap: () => homeViewModel.onAllRoomsTitleTapped(),
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

        // Room Categories as grid - Fixed height to prevent overflow
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
            itemCount: roomCategories.length,
            itemBuilder: (context, index) {
              final room = roomCategories[index];
              return _buildRoomCard(context, homeViewModel, room);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItemCard(BuildContext context, HomeViewModel homeViewModel, Map<String, String> item) {
    return GestureDetector(
      onTap: () => homeViewModel.onFurnitureItemTapped(item['id']!),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Furniture Image
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
                  Icons.chair,
                  color: AppColors.getPrimaryColor(context),
                  size: 30
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

  Widget _buildRoomCard(BuildContext context, HomeViewModel homeViewModel, Map<String, String> room) {
    return GestureDetector(
      onTap: () {
        homeViewModel.onRoomTapped(room['id']!);
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
              _getRoomIcon(room['type']!),
              size: 40,
              color: AppColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 8),
            Text(
              room['name']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
            Text(
              'Catalogue Page',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, HomeViewModel homeViewModel) {
    return BottomNavBar(
      currentIndex: homeViewModel.selectedIndex,
      onTap: (index) => homeViewModel.onTabSelected(index),
    );
  }

  IconData _getRoomIcon(String roomType) {
    switch (roomType.toLowerCase()) {
      case 'living_room':
        return Icons.living;
      case 'dining_room':
        return Icons.dining;
      case 'bedroom':
        return Icons.bed;
      case 'kitchen':
        return Icons.kitchen;
      case 'bathroom':
        return Icons.bathtub;
      case 'office':
        return Icons.work;
      default:
        return Icons.room;
    }
  }
}