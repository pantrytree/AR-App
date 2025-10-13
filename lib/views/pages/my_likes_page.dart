import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/my_likes_page_viewmodel.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_components.dart';
import '../../views/widgets/bottom_nav_bar.dart';


/// TODO (Backend Integration Notes):
/// - Connect category tabs and liked item data with real backend responses from `/likes`.
/// - Replace placeholder icons and images with actual product thumbnails.
/// - Connect navigation buttons (bottom bar and "Explore" button) to real pages once ready.
class MyLikesPage extends StatefulWidget {
  const MyLikesPage({super.key});

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup for pulsing "Explore" buttons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load placeholder liked items once the UI has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyLikesViewModel>(context, listen: false).loadLikedItems();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          TextComponents.myLikesTitle(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        centerTitle: true,
      ),

      // Consumer listens to ViewModel updates and rebuilds UI accordingly
      body: Consumer<MyLikesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            // Show error message if data loading fails
            return Center(
              child: Text(
                  TextComponents.errorLoadingLikes(viewModel.errorMessage!)),
            );
          }

          // Show either empty state or liked items grid
          return Column(
            children: [
              _buildCategoryTabs(viewModel),
              Expanded(
                child: viewModel.likedItems.isEmpty
                    ? _buildEmptyState()
                    : Column(
                  children: [
                    Expanded(child: _buildProductGrid(viewModel)),
                    _buildExploreMoreButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Likes page is index 1 in navigation bar
        onTap: (index) {
          // TODO (Navigation): Replace placeholder routes with actual named routes once pages are ready
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/likes');
              break;
            case 2:
              Navigator.pushNamed(context, '/camera');
              break;
            case 3:
              Navigator.pushNamed(context, '/shopping');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  /// Builds the category tabs for filtering liked items.
  /// Each tab updates the selected category in the ViewModel.
  Widget _buildCategoryTabs(MyLikesViewModel viewModel) {
    return Container(
      color: AppColors.secondaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: viewModel.categories.map((category) {
          final isSelected = category == viewModel.selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildCategoryTab(category, isSelected, viewModel),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTab(
      String category, bool isSelected, MyLikesViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.setSelectedCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.likesTabSelected
              : AppColors.likesTabUnselected,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.likesTabSelected
                : AppColors.likesTabUnselected,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.primaryDarkBlue,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Builds the empty state UI shown when the user has no liked items.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: AppColors.likesHeart),
          const SizedBox(height: 16),
          Text(
            TextComponents.noLikedItemsYet(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TextComponents.likedItemsDescription(),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: 20),
          // TODO (Navigation): Connect this button to the real Explore page
          _buildPulsingExploreButton(TextComponents.exploreProducts()),
        ],
      ),
    );
  }

  /// Builds the grid layout for displaying liked items.
  /// Each card shows product name, dimensions, and a heart icon for unliking.
  Widget _buildProductGrid(MyLikesViewModel viewModel) {
    final filteredItems = viewModel.getFilteredItems();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) =>
          _buildProductCard(filteredItems[index], viewModel),
    );
  }

  /// Builds each liked product card.
  /// TODO (Backend): Replace placeholder icon with product image from backend.
  Widget _buildProductCard(dynamic item, MyLikesViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder product image area
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.chair, size: 40, color: AppColors.primaryPurple),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Item Name',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['dimensions'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Heart icon for removing from likes
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => viewModel.removeLikedItem(item['id']),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.favorite, color: AppColors.likesHeart, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds a pulsing "Explore More Products" button below the grid.
  /// TODO (Navigation): Connect this button to Explore page once available.
  Widget _buildExploreMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _buildPulsingExploreButton(TextComponents.exploreMoreProducts()),
    );
  }

  /// Shared button animation for both "Explore" buttons.
  Widget _buildPulsingExploreButton(String text) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        onPressed: () => Navigator.pushNamed(context, '/explore'), // TODO: Replace with real route
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
