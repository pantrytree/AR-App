import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';
import '/theme/theme.dart';
import '/services/furniture_service.dart';
import '/services/favorites_service.dart';
import '/models/furniture_item.dart';

// Detailed product page for individual furniture items
// Displays item information, images, and related products
class CatalogueItemPage extends StatefulWidget {
  final String? productId;

  const CatalogueItemPage({
    super.key,
    this.productId,
  });

  @override
  State<CatalogueItemPage> createState() => _CatalogueItemPageState();
}

class _CatalogueItemPageState extends State<CatalogueItemPage> {
  final FurnitureService _furnitureService = FurnitureService();
  final FavoritesService _favoritesService = FavoritesService();

  FurnitureItem? _furnitureItem;      // Current furniture item being displayed
  List<FurnitureItem> _relatedItems = []; // Similar items for recommendations
  bool _isFavorite = false;           
  bool _isLoading = true;             
  bool _isLoadingFavorite = false;    
  String? _errorMessage;              

  @override
  void initState() {
    super.initState();
    _loadFurnitureData(); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get productId from arguments if not provided in constructor
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final productId = widget.productId ?? args?['productId'];

    // Reload if productId changes (e.g., from related items navigation)
    if (productId != null && _furnitureItem?.id != productId) {
      _loadFurnitureData();
    }
  }

  // Loads furniture item data, favorite status, and related items
  Future<void> _loadFurnitureData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get productId from arguments or widget property
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final productId = widget.productId ?? args?['productId'];

      if (productId == null) {
        throw Exception('No product ID provided');
      }

      print('Loading furniture item: $productId');

      // Load furniture item details
      final item = await _furnitureService.getFurnitureItem(productId);

      // Check if item is in user's favorites
      final isFav = await _favoritesService.isFavorite(productId);

      // Track user view for analytics
      await _furnitureService.trackItemView(productId);

      // Load related items based on category
      final related = await _furnitureService.getFurnitureItems(
        category: item.category,
        useFirestore: true,
      );

      // Remove current item and limit to 3 related items
      final filteredRelated = related.where((i) => i.id != productId).take(3).toList();

      if (mounted) {
        setState(() {
          _furnitureItem = item;
          _isFavorite = isFav;
          _relatedItems = filteredRelated;
          _isLoading = false;
        });
      }

      print('Loaded furniture item: ${item.name}');
    } catch (e) {
      print('Error loading furniture: $e');

      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load furniture details';
          _isLoading = false;
        });
      }
    }
  }

  // Toggles favorite status for the current furniture item
  Future<void> _toggleFavorite() async {
    if (_furnitureItem == null || _isLoadingFavorite) return;

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      print('Toggling favorite for: ${_furnitureItem!.id}');

      final newStatus = await _favoritesService.toggleFavorite(_furnitureItem!.id);

      if (mounted) {
        setState(() {
          _isFavorite = newStatus;
          _isLoadingFavorite = false;
        });

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: newStatus ? Colors.green : Colors.grey,
          ),
        );

        print('Favorite toggled: $newStatus');
      }
    } catch (e) {
      print('Error toggling favorite: $e');

      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });

        // Show error feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigates to AR view to place furniture in real space
  void _openInAR() {
    if (_furnitureItem == null) return;

    print('Opening in AR: ${_furnitureItem!.name}');

    Navigator.pushNamed(
      context,
      '/camera-page',
      arguments: {
        'furnitureItem': _furnitureItem,
      },
    );
  }

  // Navigates to a related furniture item page
  void _navigateToRelatedItem(String productId) {
    Navigator.pushReplacementNamed(
      context,
      '/catalogue-item',
      arguments: {'productId': productId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          appBar: AppBar(
            title: Text(
              "Furniture Details",
              style: TextStyle(
                color: AppColors.getAppBarForeground(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.getAppBarBackground(context),
            foregroundColor: AppColors.getAppBarForeground(context),
            elevation: 0,
            iconTheme: IconThemeData(
              color: AppColors.getAppBarForeground(context),
            ),
            actions: [
              // Refresh button to reload item data
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadFurnitureData,
              ),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  // Builds main content based on current state
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null || _furnitureItem == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadFurnitureData, // Pull to refresh functionality
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), // Item name and basic info
            const SizedBox(height: 20),
            _buildImage(), // Main product image
            const SizedBox(height: 20),
            _buildDescription(), // Item description and details
            const SizedBox(height: 30),
            _buildActionButtons(), // AR and favorite buttons
            const SizedBox(height: 30),
            _buildRelatedItemsSection(), // Similar items recommendations
          ],
        ),
      ),
    );
  }

  /// Loading state with progress indicator
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
            'Loading furniture details...',
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Error state with retry option
  Widget _buildErrorState() {
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
              'Failed to load furniture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please try again',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFurnitureData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // Header section with item name, dimensions, and category
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _furnitureItem!.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (_furnitureItem!.dimensions != null) ...[
              Icon(
                Icons.straighten,
                size: 16,
                color: AppColors.getSecondaryTextColor(context),
              ),
              const SizedBox(width: 4),
              Text(
                _furnitureItem!.dimensions!,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
            const SizedBox(width: 16),
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _furnitureItem!.category,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Main product image with loading and error states
  Widget _buildImage() {
    return Container(
      height: 250,
      width: double.infinity,
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
      child: _furnitureItem!.imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _furnitureItem!.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.getPrimaryColor(context),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(); // Fallback for failed image load
          },
        ),
      )
          : _buildPlaceholderImage(), // Fallback for missing image URL
    );
  }

  // Placeholder icon when image is unavailable
  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        _getCategoryIcon(_furnitureItem!.category),
        size: 60,
        color: AppColors.getPrimaryColor(context),
      ),
    );
  }

  // Item description and additional details
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _furnitureItem!.description,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getTextColor(context),
            height: 1.5,
          ),
        ),
        if (_furnitureItem!.color != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.palette,
                size: 20,
                color: AppColors.getSecondaryTextColor(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Color: ${_furnitureItem!.color}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Action buttons for AR viewing and favoriting
  Widget _buildActionButtons() {
    return Row(
      children: [
        // AR View button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openInAR,
            icon: const Icon(Icons.view_in_ar),
            label: const Text("Open in AR"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimaryColor(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Favorite button with loading state
        Container(
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
          child: _isLoadingFavorite
              ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.getPrimaryColor(context),
              ),
            ),
          )
              : IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 30,
              color: _isFavorite
                  ? AppColors.likesHeart
                  : AppColors.getPrimaryColor(context),
            ),
          ),
        ),
      ],
    );
  }

  // Related/similar items section
  Widget _buildRelatedItemsSection() {
    if (_relatedItems.isEmpty) {
      return const SizedBox.shrink(); // Hide section if no related items
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Similar Furniture",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        ..._relatedItems.map((item) => _buildRelatedItem(context, item)),
      ],
    );
  }

  // Individual related item widget
  Widget _buildRelatedItem(BuildContext context, FurnitureItem item) {
    return GestureDetector(
      onTap: () => _navigateToRelatedItem(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            // Furniture image or icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    _getCategoryIcon(item.category),
                    color: AppColors.getPrimaryColor(context),
                  ),
                ),
              )
                  : Icon(
                _getCategoryIcon(item.category),
                color: AppColors.getPrimaryColor(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  if (item.dimensions != null)
                    Text(
                      item.dimensions!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ],
        ),
      ),
    );
  }

  // Returns appropriate icon based on furniture category
  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('chair')) return Icons.chair_rounded;
    if (lowerCategory.contains('sofa')) return Icons.weekend_rounded;
    if (lowerCategory.contains('table')) return Icons.table_restaurant_rounded;
    if (lowerCategory.contains('bed')) return Icons.bed_rounded;
    if (lowerCategory.contains('lamp') || lowerCategory.contains('light')) {
      return Icons.light_rounded;
    }
    if (lowerCategory.contains('cabinet') || lowerCategory.contains('storage')) {
      return Icons.kitchen_rounded;
    }
    return Icons.chair_rounded; // Default icon
  }
}
