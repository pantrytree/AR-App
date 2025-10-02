import 'package:flutter/material.dart';
import 'side_menu.dart';
import 'bottom_nav_bar.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class HomePage extends StatefulWidget {
  final String? userName;

  const HomePage({
    super.key,
    this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  late final List<Widget> _pages = [
    const HomeScreen(),
    _buildPlaceholderPage(TextComponents.arViewTitle),
    _buildPlaceholderPage(TextComponents.cartPageTitle),
    _buildPlaceholderPage(TextComponents.favoritesTitle),
    _buildPlaceholderPage(TextComponents.profilePageTitle),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextComponents.appTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: SideMenu(userName: widget.userName),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              const HomeHeader(),
              // Recently Used Section
              const RecentlyUsedSection(),
              // All Rooms Section
              const AllRoomsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextComponents.homeGreeting,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TextComponents.homeWelcome,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class RecentlyUsedSection extends StatelessWidget {
  const RecentlyUsedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextComponents.recentlyUsedTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRecentlyUsedItem(TextComponents.recentItemBeigeCouch, context),
                const SizedBox(width: 12),
                _buildRecentlyUsedItem(TextComponents.recentItemPinkBed, context),
                const SizedBox(width: 12),
                _buildRecentlyUsedItem(TextComponents.recentItemSilver, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyUsedItem(String titleId, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to catalogue item page
        Navigator.pushNamed(context, '/catalogue_item');
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            titleId,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class AllRoomsSection extends StatelessWidget {
  const AllRoomsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            TextComponents.allRoomsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: TextComponents.searchPlaceholder,
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.textLight),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Room Categories Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildRoomCategory(TextComponents.roomCategoryLiving, context),
              _buildRoomCategory(TextComponents.roomCategoryBedroom, context),
              _buildRoomCategory(TextComponents.roomCategoryKitchen, context),
              _buildRoomCategory(TextComponents.roomCategoryOffice, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCategory(String categoryId, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to catalogue page
        Navigator.pushNamed(context, '/catalogue');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            categoryId,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}