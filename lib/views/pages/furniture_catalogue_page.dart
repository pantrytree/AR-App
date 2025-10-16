import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_model.dart';
import '../../services/furniture_service.dart';
import '../../services/likes_service.dart';
import '../../utils/colors.dart';
import '/views/pages/roomielab_screen.dart'; // Add this import for AR navigation

class FurnitureCataloguePage extends StatefulWidget {
  final String? initialRoom;
  final String? initialType;
  final String? itemToShowDetails;

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

  // Filter states
  String _selectedRoom = 'all';
  String _selectedType = 'all';
  String _selectedStyle = 'all';
  String _selectedColor = 'all';
  String _searchQuery = '';

  List<FurnitureItem> _filteredItems = [];
  bool _hasShownInitialPopup = false;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.initialRoom?.toLowerCase() ?? 'all';
    _selectedType = widget.initialType?.toLowerCase() ?? 'all';
    _applyFilters();

    // Show details for specific item if provided
    if (widget.itemToShowDetails != null && !_hasShownInitialPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasShownInitialPopup) {
          _showDetailsForItem(widget.itemToShowDetails!);
          _hasShownInitialPopup = true;
        }
      });
    }
  }

  void _showDetailsForItem(String itemName) {
    final matchingItems = FurnitureService.allFurniture.where(
          (furniture) => furniture.name.toLowerCase().contains(itemName.toLowerCase()),
    ).toList();

    if (matchingItems.isNotEmpty) {
      // Use the first matching item
      final furnitureItem = matchingItems.first;

      // Apply filters to show the specific item's category
      setState(() {
        _selectedRoom = furnitureItem.roomCategory.toLowerCase();
        _selectedType = furnitureItem.furnitureType.toLowerCase();
        _applyFilters();
      });

      // Wait a bit for the grid to update, then show the dialog
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showFurnitureDetails(context, furnitureItem);
        }
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = FurnitureService.allFurniture.where((item) {
        bool roomMatch = _selectedRoom == 'all' || item.roomCategory.toLowerCase() == _selectedRoom;
        bool typeMatch = _selectedType == 'all' || item.furnitureType.toLowerCase() == _selectedType;
        bool styleMatch = _selectedStyle == 'all' || item.style.toLowerCase() == _selectedStyle;
        bool colorMatch = _selectedColor == 'all' || item.colors.any((color) => color.toLowerCase() == _selectedColor);
        bool searchMatch = _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());

        return roomMatch && typeMatch && styleMatch && colorMatch && searchMatch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedRoom = 'all';
      _selectedType = 'all';
      _selectedStyle = 'all';
      _selectedColor = 'all';
      _searchQuery = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  void _toggleLike(FurnitureItem furniture, LikesService likesService) {
    likesService.toggleLike(furniture);
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
          _getAppBarTitle(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
        actions: [
          if (_hasActiveFilters())
            IconButton(
              icon: Icon(
                Icons.clear_all,
                color: AppColors.getAppBarForeground(context),
              ),
              onPressed: _clearFilters,
              tooltip: 'Clear All Filters',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          SizedBox(
            height: 60,
            child: _buildFilterChips(),
          ),
          _buildResultsCount(),
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : _buildFurnitureGrid(),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    if (_selectedRoom != 'all') {
      return '${_selectedRoom.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')} Furniture';
    }
    if (_selectedType != 'all') {
      return '${_selectedType[0].toUpperCase() + _selectedType.substring(1)} Furniture';
    }
    if (widget.itemToShowDetails != null) {
      return 'Furniture Details';
    }
    return 'Furniture Catalogue';
  }

  bool _hasActiveFilters() {
    return _selectedRoom != 'all' || _selectedType != 'all' || _selectedStyle != 'all' || _selectedColor != 'all' || _searchQuery.isNotEmpty;
  }

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
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Rooms', _selectedRoom, [
            _FilterOption('all', 'All Rooms'),
            _FilterOption('living room', 'Living Room'),
            _FilterOption('bedroom', 'Bedroom'),
            _FilterOption('office', 'Office'),
            _FilterOption('dining', 'Dining'),
            _FilterOption('kitchen', 'Kitchen'),
          ], (value) {
            setState(() {
              _selectedRoom = value;
              _applyFilters();
            });
          }),

          const SizedBox(width: 8),

          _buildFilterChip('Type', _selectedType, [
            _FilterOption('all', 'All Types'),
            _FilterOption('bed', 'Beds'),
            _FilterOption('sofa', 'Sofas'),
            _FilterOption('chair', 'Chairs'),
            _FilterOption('table', 'Tables'),
            _FilterOption('lamp', 'Lamps'),
            _FilterOption('wardrobe', 'Wardrobes'),
          ], (value) {
            setState(() {
              _selectedType = value;
              _applyFilters();
            });
          }),

          const SizedBox(width: 8),

          _buildFilterChip('Style', _selectedStyle, [
            _FilterOption('all', 'All Styles'),
            _FilterOption('modern', 'Modern'),
            _FilterOption('traditional', 'Traditional'),
            _FilterOption('minimalist', 'Minimalist'),
            _FilterOption('industrial', 'Industrial'),
          ], (value) {
            setState(() {
              _selectedStyle = value;
              _applyFilters();
            });
          }),

          const SizedBox(width: 8),

          _buildFilterChip('Color', _selectedColor, [
            _FilterOption('all', 'All Colors'),
            _FilterOption('pink', 'Pink'),
            _FilterOption('white', 'White'),
            _FilterOption('grey', 'Grey'),
            _FilterOption('black', 'Black'),
            _FilterOption('brown', 'Brown'),
            _FilterOption('silver', 'Silver'),
            _FilterOption('beige', 'Beige'),
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

  Widget _buildFilterChip(
      String title,
      String selectedValue,
      List<_FilterOption> options,
      Function(String) onSelected,
      ) {
    final selectedOption = options.firstWhere((opt) => opt.value == selectedValue);
    final isSelected = selectedValue != 'all';

    return GestureDetector(
      onTap: () {
        _showFilterOptions(title, options, selectedValue, onSelected);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getCategoryTabSelected(context)
              : AppColors.getCategoryTabUnselected(context),
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
              const Icon(Icons.close, size: 16, color: AppColors.white),
            ],
          ],
        ),
      ),
    );
  }

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
                          ? Icon(Icons.check, color: AppColors.primaryPurple)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(option.value);
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
          if (_hasActiveFilters()) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearFilters,
              child: Text(
                'Clear filters',
                style: GoogleFonts.inter(
                  color: AppColors.primaryPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFurnitureGrid() {
    return Consumer<LikesService>(
      builder: (context, likesService, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _filteredItems.length,
          itemBuilder: (context, index) {
            final furniture = _filteredItems[index];
            return _buildFurnitureCard(furniture, likesService);
          },
        );
      },
    );
  }

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
                'Try adjusting your filters or search terms',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
              ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFurnitureCard(FurnitureItem furniture, LikesService likesService) {
    final isLiked = likesService.isLiked(furniture.id);

    return GestureDetector(
      onTap: () {
        _showFurnitureDetails(context, furniture);
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
            // Image section - reduced height
            Container(
              height: 100, // Reduced from 120
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getFurnitureIcon(furniture.furnitureType),
                      size: 35, // Reduced from 40
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 6, // Adjusted
                    right: 6, // Adjusted
                    child: GestureDetector(
                      onTap: () => _toggleLike(furniture, likesService),
                      child: Container(
                        width: 22, // Reduced
                        height: 22, // Reduced
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
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
                          size: 12, // Reduced from 14
                          color: isLiked ? AppColors.primaryLightPurple : AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content section - reduced padding and spacing
            Container(
              height: 90, // Reduced from 110
              padding: const EdgeInsets.all(10), // Reduced from 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        furniture.name,
                        style: GoogleFonts.inter(
                          fontSize: 13, // Reduced from 14
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // Reduced from 4
                      Text(
                        '${furniture.roomCategory} • ${furniture.furnitureType}',
                        style: GoogleFonts.inter(
                          fontSize: 11, // Reduced from 12
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
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12, // Reduced from 14
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 2), // Reduced from 4
                          Text(
                            '${furniture.rating}',
                            style: GoogleFonts.inter(
                              fontSize: 11, // Reduced from 12
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(width: 2), // Reduced from 4
                          Text(
                            '(${furniture.reviewCount})',
                            style: GoogleFonts.inter(
                              fontSize: 11, // Reduced from 12
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2), // Reduced from 4
                      SizedBox(
                        height: 18, // Reduced from 20
                        child: Wrap(
                          spacing: 3, // Reduced from 4
                          runSpacing: 3, // Reduced from 4
                          children: [
                            ...furniture.colors.take(2).map((color) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // Reduced
                              decoration: BoxDecoration(
                                color: AppColors.getCardBackground(context),
                                borderRadius: BorderRadius.circular(3), // Reduced
                                border: Border.all(color: AppColors.getSecondaryTextColor(context).withOpacity(0.3)),
                              ),
                              child: Text(
                                color,
                                style: GoogleFonts.inter(
                                  fontSize: 9, // Reduced from 10
                                  color: AppColors.getSecondaryTextColor(context),
                                ),
                              ),
                            )),
                            if (furniture.colors.length > 2)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // Reduced
                                decoration: BoxDecoration(
                                  color: AppColors.getCardBackground(context),
                                  borderRadius: BorderRadius.circular(3), // Reduced
                                  border: Border.all(color: AppColors.getSecondaryTextColor(context).withOpacity(0.3)),
                                ),
                                child: Text(
                                  '+${furniture.colors.length - 2} more',
                                  style: GoogleFonts.inter(
                                    fontSize: 9, // Reduced from 10
                                    color: AppColors.getSecondaryTextColor(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              Text(
                furniture.description,
                style: GoogleFonts.inter(
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Details:',
                style: GoogleFonts.inter(
                  color: AppColors.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text('• Room: ${furniture.roomCategory}'),
              Text('• Type: ${furniture.furnitureType}'),
              Text('• Style: ${furniture.style}'),
              Text('• Material: ${furniture.material}'),
              Text('• Colors: ${furniture.colors.join(', ')}'),
              Text('• Sizes: ${furniture.sizes.join(', ')}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: AppColors.primaryPurple),
                  const SizedBox(width: 4),
                  Text('${furniture.rating} (${furniture.reviewCount} reviews)'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _navigateToARView(context); // Navigate to AR view
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('View in AR'),
          ),
        ],
      ),
    );
  }

  void _navigateToARView(BuildContext context) {
    // Navigate to the AR camera page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RoomieLabScreen(), // Use your AR screen
      ),
    );
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
        return Icons.widgets;
    }
  }
}

class _FilterOption {
  final String value;
  final String label;

  _FilterOption(this.value, this.label);
}