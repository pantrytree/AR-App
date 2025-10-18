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
import '/views/pages/my_likes_page.dart';
import '/views/pages/settings_page.dart';
import '/views/pages/help_page.dart';
import '/views/pages/about_page.dart';
import '/views/pages/roomielab_screen.dart';
import '/models/furniture_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel.instance,
        ),
        ChangeNotifierProvider(create: (_) => SideMenuViewModel()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<HomeViewModel>(
            builder: (context, homeViewModel, child) {
              // Handle navigation only once
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (ModalRoute.of(context)?.isCurrent ?? false) {
                  homeViewModel.resetToHome();
                }
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (homeViewModel.navigateToRoute != null) {
                  final route = homeViewModel.navigateToRoute!;
                  final arguments = homeViewModel.navigationArguments;

                  // Clear navigation BEFORE navigating to prevent multiple triggers
                  homeViewModel.clearNavigation();

                  Navigator.pushNamed(
                    context,
                    route,
                    arguments: arguments,
                  );
                }
              });

              return Scaffold(
                backgroundColor: AppColors.getBackgroundColor(context),
                appBar: AppBar(
                  backgroundColor: AppColors.getAppBarBackground(context),
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: AppColors.getAppBarForeground(context),
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
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
    if (!homeViewModel.isUserDataLoaded) {
      return _buildUserDataLoadingState(context);
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TextComponents.homeGreeting(homeViewModel.userDisplayName),
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
      ),
    );
  }

  Widget _buildUserDataLoadingState(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton loading for greeting
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 32),
              _buildRecentlyUsedSection(context, HomeViewModel.instance),
              const SizedBox(height: 32),
              _buildAllRoomsSection(context, HomeViewModel.instance),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyUsedSection(BuildContext context, HomeViewModel homeViewModel) {
    // Use real recently viewed items from backend
    final recentItems = homeViewModel.recentlyViewedItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            homeViewModel.navigateToCatalogue();
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
        // Show message if no recent items
        if (recentItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  color: AppColors.getSecondaryTextColor(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No recently viewed items yet. Start browsing!',
                    style: TextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
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
    // Use real room categories from backend
    final roomCategories = homeViewModel.roomCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to catalogue showing all rooms (no filter)
            homeViewModel.onAllCategoriesTapped();
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
        // Show message if no rooms
        if (roomCategories.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No rooms available',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
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
      ],
    );
  }

  Widget _buildRecentItemCard(
      BuildContext context,
      HomeViewModel homeViewModel,
      FurnitureItem item,
      ) {
    return GestureDetector(
      onTap: () {
        homeViewModel.onFurnitureItemTapped(item.id);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                image: item.imageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(item.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: item.imageUrl == null
                  ? Icon(
                _getFurnitureIcon(item.category),
                color: AppColors.getPrimaryColor(context),
                size: 30,
              )
                  : null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 90, // Slightly less than container width for padding
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 11, // Slightly smaller font
                  color: AppColors.getTextColor(context),
                  fontWeight: FontWeight.w500,
                  height: 1.2, // Better line spacing
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(
      BuildContext context,
      HomeViewModel homeViewModel,
      Map<String, dynamic> room,
      ) {
    final roomName = room['name'] as String;
    final itemCount = room['itemCount'] as String;
    final iconName = room['icon'] as String?;

    return GestureDetector(
      onTap: () {
        print('Room tapped: $roomName');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FurnitureCataloguePage(
              initialRoom: roomName,
            ),
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
              _getRoomIcon(iconName ?? 'widgets'),
              size: 40,
              color: AppColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 8),
            Text(
              roomName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$itemCount items',
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

  IconData _getRoomIcon(String iconName) {
    final iconMap = {
      'weekend': Icons.weekend,
      'bed': Icons.bed,
      'work': Icons.work,
      'kitchen': Icons.kitchen,
      'dining': Icons.dining,
      'bathtub': Icons.bathtub,
      'chair': Icons.chair,
      'table_restaurant': Icons.table_restaurant,
      'lightbulb': Icons.lightbulb,
      'weekend_outlined': Icons.weekend_outlined,
    };
    return iconMap[iconName] ?? Icons.widgets;
  }

  IconData _getFurnitureIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bed':
        return Icons.bed;
      case 'sofa':
      case 'couch':
        return Icons.weekend;
      case 'chair':
        return Icons.chair;
      case 'table':
        return Icons.table_restaurant;
      case 'lamp':
        return Icons.lightbulb;
      case 'cabinet':
      case 'wardrobe':
        return Icons.king_bed;
      default:
        return Icons.chair;
    }
  }
}