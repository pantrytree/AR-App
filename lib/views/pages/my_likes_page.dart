import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/viewmodels/my_likes_page_viewmodel.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/utils/text_components.dart';
import 'catalogue_item_page.dart';
import 'catalogue_page.dart';
import '/models/furniture_item.dart';

/// Enhanced My Likes Page with better functionality
/// - Real-time favorites synchronization
/// - Improved UI/UX
/// - Better error handling
/// - Optimized performance
class MyLikesPage extends StatefulWidget {
  const MyLikesPage({super.key});

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  bool get wantKeepAlive => true;

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

    // Load liked items from backend once the UI has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // Load initial data from viewmodel
  Future<void> _loadInitialData() async {
    final viewModel = Provider.of<MyLikesViewModel>(context, listen: false);
    await viewModel.loadLikedItems();
  }

  // Navigate to item details page
  void _navigateToItemDetails(BuildContext context, FurnitureItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogueItemPage(
          productId: item.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          appBar: _buildAppBar(context),
          body: _buildBody(),
        );
      },
    );
  }

  // Build app bar with back button and refresh
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.getAppBarBackground(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.getAppBarForeground(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        TextComponents.myLikesTitle(),
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.getAppBarForeground(context),
        ),
      ),
      centerTitle: true,
      actions: [
        // Refresh button
        Consumer<MyLikesViewModel>(
          builder: (context, viewModel, child) {
            return IconButton(
              icon: viewModel.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(
                Icons.refresh,
                color: AppColors.getAppBarForeground(context),
              ),
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.refreshLikedItems(),
            );
          },
        ),
      ],
    );
  }

  // Main body content
  Widget _buildBody() {
    return Consumer<MyLikesViewModel>(
      builder: (context, viewModel, child) {
        // Show loading state only on initial load
        if (viewModel.isLoading && viewModel.likedItems.isEmpty) {
          return _buildLoadingState();
        }

        // Show error state if there's an error and no items
        if (viewModel.errorMessage != null && viewModel.likedItems.isEmpty) {
          return _buildErrorState(context, viewModel);
        }

        // Show empty state or content
        return RefreshIndicator(
          onRefresh: () => viewModel.refreshLikedItems(),
          child: _buildContent(context, viewModel),
        );
      },
    );
  }

  // Loading spinner
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.getPrimaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your favorites...',
            style: GoogleFonts.inter(
              color: AppColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Error state display
  Widget _buildErrorState(BuildContext context, MyLikesViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load favorites',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.loadLikedItems(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // Main content area
  Widget _buildContent(BuildContext context, MyLikesViewModel viewModel) {
    return Column(
      children: [
        _buildCategoryTabs(context, viewModel),
        Expanded(
          child: viewModel.likedItems.isEmpty
              ? _buildEmptyState(context)
              : _buildLikedItemsGrid(context, viewModel),
        ),
      ],
    );
  }

  // Grid of liked items
  Widget _buildLikedItemsGrid(BuildContext context, MyLikesViewModel viewModel) {
    final filteredItems = viewModel.getFilteredItems();

    if (filteredItems.isEmpty) {
      return _buildNoItemsInCategory(context, viewModel);
    }

    return Column(
      children: [
        _buildItemsCount(context, viewModel),
        Expanded(
          child: _buildFurnitureGrid(context, viewModel, filteredItems),
        ),
        _buildExploreMoreButton(context),
      ],
    );
  }

  // Category filter tabs
  Widget _buildCategoryTabs(BuildContext context, MyLikesViewModel viewModel) {
    return Container(
      color: AppColors.getBackgroundColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: viewModel.categories.map((category) {
            return _buildCategoryTab(context, category, viewModel);
          }).toList(),
        ),
      ),
    );
  }

  // Individual category tab
  Widget _buildCategoryTab(
      BuildContext context,
      String category,
      MyLikesViewModel viewModel,
      ) {
    final isSelected = category == viewModel.selectedCategory;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (_) => viewModel.setSelectedCategory(category),
        label: Text(
          category,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.getTextColor(context),
          ),
        ),
        selectedColor: AppColors.getPrimaryColor(context),
        backgroundColor: AppColors.getCardBackground(context),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Items count display
  Widget _buildItemsCount(BuildContext context, MyLikesViewModel viewModel) {
    final filteredCount = viewModel.getFilteredItems().length;
    final totalCount = viewModel.likedItems.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Showing $filteredCount of $totalCount items',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const Spacer(),
          if (viewModel.selectedCategory != 'All')
            GestureDetector(
              onTap: () => viewModel.setSelectedCategory('All'),
              child: Text(
                'Show all',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.getPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Empty state when no liked items
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: AppColors.likesHeart.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              TextComponents.noLikedItemsYet(),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start exploring and save your favorite furniture items to see them here',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildPulsingExploreButton(context, 'Explore Furniture'),
          ],
        ),
      ),
    );
  }

  // No items in selected category
  Widget _buildNoItemsInCategory(BuildContext context, MyLikesViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No items in ${viewModel.selectedCategory}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category or explore more furniture',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPulsingExploreButton(context, 'Explore More'),
          ],
        ),
      ),
    );
  }

  // Grid view of furniture items
  Widget _buildFurnitureGrid(
      BuildContext context,
      MyLikesViewModel viewModel,
      List<FurnitureItem> filteredItems,
      ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) => _buildFurnitureCard(
        context,
        filteredItems[index],
        viewModel,
      ),
    );
  }

  // Individual furniture card
  Widget _buildFurnitureCard(
      BuildContext context,
      FurnitureItem item,
      MyLikesViewModel viewModel,
      ) {
    return GestureDetector(
      onTap: () {
        _navigateToItemDetails(context, item);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 180,
            maxHeight: 200,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildItemImage(item),
                  Expanded(
                    child: _buildItemDetails(item),
                  ),
                ],
              ),
              // Favorite button
              _buildFavoriteButton(context, item, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  // Item image display
  Widget _buildItemImage(FurnitureItem item) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLightPurple.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
          ? ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(item),
        ),
      )
          : _buildPlaceholderIcon(item),
    );
  }

  // Placeholder icon when no image
  Widget _buildPlaceholderIcon(FurnitureItem item) {
    return Center(
      child: Icon(
        _getCategoryIcon(item.category),
        size: 40,
        color: AppColors.getPrimaryColor(context),
      ),
    );
  }

  // Item details text
  Widget _buildItemDetails(FurnitureItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              item.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          if (item.dimensions?.isNotEmpty ?? false)
            Text(
              item.dimensions!,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.getSecondaryTextColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 4),

          if (item.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                item.category,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.getPrimaryColor(context),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // Favorite button to remove item
  Widget _buildFavoriteButton(
      BuildContext context,
      FurnitureItem item,
      MyLikesViewModel viewModel,
      ) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () => _showRemoveConfirmation(context, item, viewModel),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.likesHeart,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Show confirmation dialog before removing
  void _showRemoveConfirmation(
      BuildContext context,
      FurnitureItem item,
      MyLikesViewModel viewModel,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove from Favorites?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to remove "${item.name}" from your favorites?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _removeItem(context, item, viewModel);
              },
              child: Text(
                'Remove',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Remove item from favorites
  Future<void> _removeItem(
      BuildContext context,
      FurnitureItem item,
      MyLikesViewModel viewModel,
      ) async {
    try {
      await viewModel.removeLikedItem(item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${item.name}" from favorites'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await viewModel.toggleFavorite(item.id);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove item'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Explore more button at bottom
  Widget _buildExploreMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildPulsingExploreButton(context, 'Explore More Furniture'),
    );
  }

  // Pulsing explore button with animation
  Widget _buildPulsingExploreButton(BuildContext context, String text) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CataloguePage()),
          );
        },
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Get icon based on category
  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('chair')) return Icons.chair_rounded;
    if (lowerCategory.contains('sofa')) return Icons.weekend_rounded;
    if (lowerCategory.contains('table')) return Icons.table_restaurant_rounded;
    if (lowerCategory.contains('bed')) return Icons.bed_rounded;
    if (lowerCategory.contains('lamp') || lowerCategory.contains('light'))
      return Icons.light_rounded;
    if (lowerCategory.contains('cabinet') || lowerCategory.contains('storage'))
      return Icons.kitchen_rounded;
    if (lowerCategory.contains('design')) return Icons.architecture_rounded;
    if (lowerCategory.contains('project')) return Icons.work_rounded;
    return Icons.photo_library_rounded;
  }
}
