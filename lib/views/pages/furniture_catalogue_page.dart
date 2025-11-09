import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/models/favorite.dart';
import '../../models/furniture_item.dart';
import '../../services/furniture_service.dart';
import '../../services/favorites_service.dart';
import '../../utils/colors.dart';
import '/views/pages/roomielab_screen.dart';
import 'catalogue_item_page.dart';

// FurnitureCataloguePage displays a filterable grid of furniture items
// Supports filtering by room, category, color, and search
class FurnitureCataloguePage extends StatefulWidget {
  final String? initialRoom; // Pre-selected room filter
  final String? initialType; // Pre-selected category filter
  final String? itemToShowDetails; // Specific item to show details for on load

  const FurnitureCataloguePage({
    super.key,
    this.initialRoom,
    this.initialType,
    this.itemToShowDetails,
  });

  @override
  State<FurnitureCataloguePage> createState() => _FurnitureCataloguePageState();
}

class _FurnitureCataloguePageState extends State<FurnitureCataloguePage> {
  final TextEditingController _searchController = TextEditingController();

  // Service instances for data operations
  final FavoritesService _favoritesService = FavoritesService();
  final FurnitureService _furnitureService = FurnitureService();

  // Filter states with default values
  String _selectedRoom = 'All';
  String _selectedType = 'All';
  String _selectedStyle = 'All';
  String _selectedColor = 'All';
  String _searchQuery = '';

  List<String> _likedItems = []; // IDs of favorited items
  List<FurnitureItem> _filteredItems = []; // Items after applying filters
  List<FurnitureItem> _allFurnitureItems = []; // All items from service
  bool _isLoading = true; // Loading state
  bool _hasShownInitialPopup = false; // Track if initial popup was shown

  @override
  void initState() {
    super.initState();

    // Initialize filters with provided values or defaults
    _selectedRoom = widget.initialRoom ?? 'All';
    _selectedType = widget.initialType ?? 'All';

    // Debug logging for initialization
    print('FurnitureCataloguePage initialized');
    print('Initial room: ${widget.initialRoom}');
    print('Initial type: ${widget.initialType}');
    print('Selected room: $_selectedRoom');
    print('Selected type: "$_selectedType"');

    // Load data on initialization
    _loadFurnitureItems();
    _loadFavorites();
  }

  // Load furniture items from the service
  Future<void> _loadFurnitureItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading furniture items...');

      // Fetch furniture items from Firestore
      List<FurnitureItem> furnitureItems = await _furnitureService.getFurnitureItems(
        useFirestore: true,
      );

      print('DEBUG: Found ${furnitureItems.length} total items in Firestore');

      // Debug information about available data
      if (furnitureItems.isNotEmpty) {
        final uniqueRooms = furnitureItems.map((item) => item.roomType).toSet().toList();
        final uniqueCategories = furnitureItems.map((item) => item.category).toSet().toList();
        print('All unique room types: $uniqueRooms');
        print('All unique categories: $uniqueCategories');
      }

      setState(() {
        _allFurnitureItems = furnitureItems;
        _isLoading = false;
        _applyFilters(); // Apply initial filters after loading
      });

      // Show details for specific item if requested (only once)
      if (widget.itemToShowDetails != null && !_hasShownInitialPopup) {
        _hasShownInitialPopup = true;
        _showDetailsForItem(widget.itemToShowDetails!);
      }

      print('After applying filters: ${_filteredItems.length} items displayed');
    } catch (e) {
      print('ERROR in _loadFurnitureItems: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Failed to load furniture items: $e');
    }
  }

  // Show details for a specific item by name
  void _showDetailsForItem(String itemName) {
    final matchingItems = _allFurnitureItems.where(
          (furniture) => furniture.name.toLowerCase().contains(itemName.toLowerCase()),
    ).toList();

    if (matchingItems.isNotEmpty) {
      final furnitureItem = matchingItems.first;
      _showFurnitureDetails(context, furnitureItem);
    }
  }

  // Apply all active filters to the furniture list
  void _applyFilters() {
    print('Applying filters...');
    print('All items count: ${_allFurnitureItems.length}');
    print('Room filter: "$_selectedRoom"');
    print('Type filter: "$_selectedType"');

    setState(() {
      _filteredItems = _allFurnitureItems.where((item) {
        // Room filter logic
        bool roomMatch = _selectedRoom == 'All';
        if (!roomMatch) {
          final selectedRoomLower = _selectedRoom.toLowerCase();
          final itemRoomLower = item.roomType.toLowerCase();

          // Flexible room matching for different naming conventions
          roomMatch = itemRoomLower == selectedRoomLower ||
              itemRoomLower.contains(selectedRoomLower) ||
              selectedRoomLower.contains(itemRoomLower);

          // Special cases for common room type variations
          if (selectedRoomLower == 'living_room' && itemRoomLower.contains('living')) {
            roomMatch = true;
          }
          if (selectedRoomLower == 'dining_room' && itemRoomLower.contains('dining')) {
            roomMatch = true;
          }
          if (selectedRoomLower == 'bedroom' && itemRoomLower.contains('bed')) {
            roomMatch = true;
          }
        }

        // Category/Type filter logic
        bool typeMatch = _selectedType == 'All';
        if (!typeMatch) {
          final selectedTypeLower = _selectedType.toLowerCase();
          final itemCategoryLower = item.category.toLowerCase();

          typeMatch = itemCategoryLower == selectedTypeLower ||
              itemCategoryLower.contains(selectedTypeLower) ||
              selectedTypeLower.contains(itemCategoryLower);
        }

        // Color filter logic
        bool colorMatch = _selectedColor == 'All' ||
            (item.color != null && item.color!.toLowerCase() == _selectedColor.toLowerCase());

        // Search filter logic (name and description)
        bool searchMatch = _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        final shouldInclude = roomMatch && typeMatch && colorMatch && searchMatch;

        return shouldInclude;
      }).toList();
    });

    print('Filtered to ${_filteredItems.length} items');
  }

  // Handle search query changes
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters(); // Re-apply filters with new search term
    });
  }

  // Reset all filters to default values
  void _clearFilters() {
    setState(() {
      _selectedRoom = 'All';
      _selectedType = 'All';
      _selectedStyle = 'All';
      _selectedColor = 'All';
      _searchQuery = '';
      _searchController.clear();
      _applyFilters(); // Re-apply with cleared filters
    });
  }

  // Load user's favorite items
  Future<void> _loadFavorites() async {
    try {
      final favorites = await _favoritesService.getFavorites();
      _likedItems = favorites.map((fav) => fav.id).toList();
      if (mounted) setState(() {}); // Update UI if widget is still mounted
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // Toggle favorite status for an item
  Future<void> _toggleFavorite(FurnitureItem furniture) async {
    try {
      await _favoritesService.toggleFavorite(furniture.id);
      await _loadFavorites(); // Reload favorites to reflect changes
    } catch (e) {
      print('Error toggling favorite: $e');
      _showErrorSnackbar('Failed to update favorites');
    }
  }

  // Show error message to user
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
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
          _getAppBarTitle(), // Dynamic title based on filters
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
        actions: [
          // Clear filters button (only shown when filters are active)
          if (_hasActiveFilters())
            IconButton(
              icon: Icon(
                Icons.clear_all,
                color: AppColors.getAppBarForeground(context),
              ),
              onPressed: _clearFilters,
              tooltip: 'Clear All Filters',
            ),
          // Refresh button
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.getAppBarForeground(context),
            ),
            onPressed: _loadFurnitureItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState() // Show loading indicator
          : Column(
        children: [
          _buildSearchBar(), // Search input field
          SizedBox(
            height: 60,
            child: _buildFilterChips(), // Filter selection chips
          ),
          _buildResultsCount(), // Results count and clear filters
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState() // Empty state when no results
                : RefreshIndicator( // Pull-to-refresh functionality
              onRefresh: _loadFurnitureItems,
              child: _buildFurnitureGrid(), // Main content grid
            ),
          ),
        ],
      ),
    );
  }

  // Loading state widget
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading furniture items...'),
        ],
      ),
    );
  }

  // Generate dynamic app bar title based on active filters
  String _getAppBarTitle() {
    if (_selectedRoom != 'All' && _selectedType != 'All') {
      return '$_selectedRoom $_selectedType';
    }
    if (_selectedRoom != 'All') {
      return '$_selectedRoom Furniture';
    }
    if (_selectedType != 'All') {
      return '${_selectedType[0].toUpperCase()}${_selectedType.substring(1)}s';
    }
    if (widget.itemToShowDetails != null) {
      return 'Furniture Details';
    }
    return 'Furniture Catalogue';
  }

  // Check if any filters are active
  bool _hasActiveFilters() {
    return _selectedRoom != 'All' ||
        _selectedType != 'All' ||
        _selectedStyle != 'All' ||
        _selectedColor != 'All' ||
        _searchQuery.isNotEmpty;
  }

  // Build search bar widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.getTextFieldBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search furniture...',
            hintStyle: GoogleFonts.inter(color: AppColors.getSecondaryTextColor(context)),
            prefixIcon: Icon(Icons.search, color: AppColors.getSecondaryTextColor(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: AppColors.getSecondaryTextColor(context)),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged(''); // Clear search
              },
            )
                : null,
          ),
        ),
      ),
    );
  }

  // Build horizontal filter chips
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Room filter chip
          _buildFilterChip('Rooms', _selectedRoom, [
            _FilterOption('All', 'All Rooms'),
            _FilterOption('Living Room', 'Living Room'),
            _FilterOption('Bedroom', 'Bedroom'),
            _FilterOption('Office', 'Office'),
            _FilterOption('Dining Room', 'Dining Room'),
            _FilterOption('Kitchen', 'Kitchen'),
            _FilterOption('Bathroom', 'Bathroom'),
          ], (value) {
            setState(() {
              _selectedRoom = value;
              _applyFilters();
            });
          }),
          const SizedBox(width: 8),
          // Category filter chip
          _buildFilterChip('Category', _selectedType, [
            _FilterOption('All', 'All Categories'),
            _FilterOption('Chair', 'Chairs'),
            _FilterOption('Sofa', 'Sofas'),
            _FilterOption('Table', 'Tables'),
            _FilterOption('Bed', 'Beds'),
            _FilterOption('Cabinet', 'Cabinets'),
            _FilterOption('Lamp', 'Lamps'),
          ], (value) {
            setState(() {
              _selectedType = value;
              _applyFilters();
            });
          }),
          const SizedBox(width: 8),
          // Color filter chip
          _buildFilterChip('Color', _selectedColor, [
            _FilterOption('All', 'All Colors'),
            _FilterOption('Brown', 'Brown'),
            _FilterOption('White', 'White'),
            _FilterOption('Black', 'Black'),
            _FilterOption('Grey', 'Grey'),
            _FilterOption('Beige', 'Beige'),
          ], (value) {
            setState(() {
              _selectedColor = value;
              _applyFilters();
            });
          }),
        ],
      ),
    );
  }

  // Build individual filter chip
  Widget _buildFilterChip(
      String title,
      String selectedValue,
      List<_FilterOption> options,
      Function(String) onSelected,
      ) {
    final selectedOption = options.firstWhere(
          (opt) => opt.value == selectedValue,
      orElse: () => options.first,
    );
    final isSelected = selectedValue != 'All'; // Check if filter is active

    return GestureDetector(
      onTap: () {
        _showFilterOptions(title, options, selectedValue, onSelected);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getCategoryTabSelected(context) // Active color
              : AppColors.getCategoryTabUnselected(context), // Inactive color
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.getCategoryTabSelected(context)
                : AppColors.getCategoryTabUnselected(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedOption.label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.white : AppColors.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 16, color: AppColors.white), // Close icon for active filters
            ],
          ],
        ),
      ),
    );
  }

  // Show filter options in bottom sheet
  void _showFilterOptions(
      String title,
      List<_FilterOption> options,
      String selectedValue,
      Function(String) onSelected,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getCardBackground(context),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select $title',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(
                        option.label,
                        style: GoogleFonts.inter(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      trailing: selectedValue == option.value
                          ? Icon(Icons.check, color: AppColors.primaryPurple) // Checkmark for selected
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(option.value); // Apply selected filter
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build results count and clear filters widget
  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredItems.length} ${_filteredItems.length == 1 ? 'item' : 'items'} found',
            style: GoogleFonts.inter(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Clear filters option (only shown when filters are active)
          if (_hasActiveFilters())
            GestureDetector(
              onTap: _clearFilters,
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 16, color: AppColors.primaryPurple),
                  const SizedBox(width: 4),
                  Text(
                    'Clear filters',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Build the main furniture grid
  Widget _buildFurnitureGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85, // Card aspect ratio
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final furniture = _filteredItems[index];
        final isLiked = _likedItems.contains(furniture.id);
        return _buildFurnitureCard(furniture, isLiked);
      },
    );
  }

  // Build empty state when no items match filters
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.getSecondaryTextColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No furniture found',
                style: GoogleFonts.inter(
                  color: AppColors.getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasActiveFilters()
                    ? 'Try adjusting your filters or search terms'
                    : 'No furniture items available',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
              ),
              // Clear filters button for empty state with active filters
              if (_hasActiveFilters()) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear All Filters'),
                ),
              ],
              const SizedBox(height: 16),
              // Refresh button
              ElevatedButton(
                onPressed: _loadFurnitureItems,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLightPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual furniture card
  Widget _buildFurnitureCard(FurnitureItem furniture, bool isLiked) {
    return GestureDetector(
      onTap: () {
        _showFurnitureDetails(context, furniture); // Show details on tap
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple.withOpacity(0.1), // Fallback color
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: furniture.imageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(furniture.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: Stack(
                children: [
                  // Fallback icon when no image
                  if (furniture.imageUrl == null)
                    Center(
                      child: Icon(
                        _getFurnitureIcon(furniture.category),
                        size: 35,
                        color: AppColors.primaryLightPurple,
                      ),
                    ),
                  // Featured badge
                  if (furniture.featured)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Featured',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(furniture),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked ? Colors.red : AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Furniture name
                        Text(
                          furniture.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Room type and category
                        Text(
                          '${furniture.roomType} • ${furniture.category}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dimensions
                        if (furniture.dimensions != null)
                          Text(
                            furniture.dimensions!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        // Color tag
                        if (furniture.color != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.getCardBackground(context),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppColors.getSecondaryTextColor(context).withOpacity(0.3)),
                            ),
                            child: Text(
                              furniture.color!,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show furniture details in a dialog
  void _showFurnitureDetails(BuildContext context, FurnitureItem furniture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          furniture.name,
          style: GoogleFonts.inter(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Furniture image
              if (furniture.imageUrl != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(furniture.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Description
              Text(
                furniture.description ?? 'No description available',
                style: GoogleFonts.inter(
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              // Details section
              Text(
                'Details:',
                style: GoogleFonts.inter(
                  color: AppColors.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text('• Room: ${furniture.roomType}'),
              Text('• Category: ${furniture.category}'),
              if (furniture.dimensions != null) Text('• Dimensions: ${furniture.dimensions}'),
              if (furniture.color != null) Text('• Color: ${furniture.color}'),
              if (furniture.arModelUrl != null) Text('• AR Model: Available'),
              const SizedBox(height: 8),
              // Featured status
              Text(
                furniture.featured ? 'Featured Item' : 'Standard Item',
                style: TextStyle(
                  color: furniture.featured
                      ? AppColors.primaryPurple
                      : AppColors.getSecondaryTextColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          // See more details button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToItemDetails(context, furniture);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('See More Details'),
          ),
        ],
      ),
    );
  }

  // Navigate to detailed item page
  void _navigateToItemDetails(BuildContext context, FurnitureItem furniture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogueItemPage(
          productId: furniture.id,
        ),
      ),
    );
  }

  // Navigate to AR view 
  void _navigateToARView(BuildContext context, FurnitureItem furniture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomieLabScreen(),
      ),
    );
  }

  // Get appropriate icon for furniture category
  IconData _getFurnitureIcon(String furnitureType) {
    switch (furnitureType.toLowerCase()) {
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
        return Icons.widgets;
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up controller
    super.dispose();
  }
}

// Helper class for filter options
class _FilterOption {
  final String value; // Internal value
  final String label; // Display label

  _FilterOption(this.value, this.label);
}
