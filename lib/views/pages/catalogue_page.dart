import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/filter_options.dart';
import '../../viewmodels/catalogue_viewmodel.dart';
import '../../utils/colors.dart';
import '../../theme/theme.dart';
import 'furniture_catalogue_page.dart';
import '/services/furniture_service.dart';
import '/models/furniture_item.dart';

class CataloguePage extends StatelessWidget {
  final String? initialRoom;

  const CataloguePage({
    super.key,
    this.initialRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ChangeNotifierProvider(
          create: (_) => CatalogueViewModel(),
          child: _CataloguePageBody(initialRoom: initialRoom),
        );
      },
    );
  }
}

class _CataloguePageBody extends StatefulWidget {
  final String? initialRoom;

  const _CataloguePageBody({
    this.initialRoom,
  });

  @override
  State<_CataloguePageBody> createState() => _CataloguePageBodyState();
}

class _CataloguePageBodyState extends State<_CataloguePageBody> {
  final FurnitureService _furnitureService = FurnitureService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  //Track room item counts from Firestore
  Map<String, int> _roomItemCounts = {};
  bool _isLoadingCounts = true;
  List<FurnitureItem> _allFurnitureItems = [];

  @override
  void initState() {
    super.initState();

    _loadFurnitureData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialRoom != null) {
        final vm = context.read<CatalogueViewModel>();
        _applyInitialRoomFilter(vm, widget.initialRoom!);
      }
    });
  }

  Future<void> _loadFurnitureData() async {
    try {
      print('Loading furniture data for catalogue...');

      // Load all furniture items
      final items = await _furnitureService.getFurnitureItems(
        useFirestore: true,
      );

      print('Loaded ${items.length} furniture items');

      // Debug: Print all furniture item IDs
      for (var item in items) {
        print('Furniture: ${item.name} (ID: ${item.id}) - Room: ${item.roomType}');
      }

      // Calculate item counts per room type
      final counts = <String, int>{};
      for (var item in items) {
        final roomType = item.roomType.toLowerCase();
        counts[roomType] = (counts[roomType] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _allFurnitureItems = items;
          _roomItemCounts = counts;
          _isLoadingCounts = false;
        });
      }

      print('Room counts: $_roomItemCounts');
    } catch (e) {
      print('Error loading furniture data: $e');
      if (mounted) {
        setState(() {
          _isLoadingCounts = false;
        });
      }
    }
  }

  void _applyInitialRoomFilter(CatalogueViewModel vm, String initialRoom) {
    final categoryMap = {
      'Living Room': 'Living Room',
      'Bedroom': 'Bedroom',
      'Office': 'Office',
      'Kitchen': 'Dining',
      'Dining Room': 'Dining',
      'Bathroom': 'Bedroom',
    };

    final targetCategory = categoryMap[initialRoom] ?? initialRoom;
    final categories = FilterOptions.categoryOptions.map((option) => option.label).toList();
    if (categories.contains(targetCategory)) {
      vm.selectCategory(targetCategory);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _navigateToCategory(String category) {
    final filterOption = FilterOptions.categoryOptions.firstWhere(
          (option) => option.label == category,
      orElse: () => FilterOptions.categoryOptions.first,
    );

    if (filterOption.value == 'all') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FurnitureCataloguePage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FurnitureCataloguePage(
            initialType: filterOption.value,
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredRooms() {
    if (_searchQuery.isEmpty) {
      return FilterOptions.roomCardOptions;
    }

    return FilterOptions.roomCardOptions.where((room) {
      final roomName = room['name'].toString().toLowerCase();
      final filterOption = room['filterOption'] as FilterOption;
      final categoryName = filterOption.label.toLowerCase();

      return roomName.contains(_searchQuery.toLowerCase()) ||
          categoryName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  int _getItemCountForRoom(String roomValue) {
    // Map filter values to room types in database
    final roomTypeMap = {
      'living_room': 'living_room',
      'bedroom': 'bedroom',
      'dining': 'dining_room',
      'office': 'office',
      'outdoor': 'outdoor',
      'all': 'all',
    };

    final mappedRoomType = roomTypeMap[roomValue.toLowerCase()] ?? roomValue.toLowerCase();

    if (mappedRoomType == 'all') {
      return _allFurnitureItems.length;
    }

    return _roomItemCounts[mappedRoomType] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();
    final filteredRooms = _getFilteredRooms();

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: AppColors.getAppBarBackground(context),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.getAppBarForeground(context)
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Catalogue',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.getAppBarForeground(context),
              ),
            ),
            iconTheme: IconThemeData(
              color: AppColors.getAppBarForeground(context),
            ),
            actions: [
              IconButton(
                icon: _isLoadingCounts
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(
                  Icons.refresh,
                  color: AppColors.getAppBarForeground(context),
                ),
                onPressed: _isLoadingCounts ? null : _loadFurnitureData,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadFurnitureData,
            child: Column(
              children: [
                _buildWelcomeSection(context),
                SizedBox(
                  height: 60,
                  child: _buildCategoryChips(context, vm),
                ),
                _buildBrowseAllSection(context, filteredRooms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primaryLightPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Our Collection',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isLoadingCounts
                ? 'Loading furniture collection...'
                : 'Discover ${_allFurnitureItems.length} furniture items for every room',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search furniture...',
                hintStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
                prefixIcon: Icon(Icons.search, color: AppColors.primaryPurple),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.primaryPurple),
                  onPressed: _clearSearch,
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, CatalogueViewModel vm) {
    final categories = FilterOptions.categoryOptions;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((filterOption) {
          final selected = filterOption.label == vm.selectedCategory;
          return _buildCategoryChip(
            filterOption,
            selected,
                () {
              vm.selectCategory(filterOption.label);
              _navigateToCategory(filterOption.label);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(FilterOption filterOption, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        child: Text(
          filterOption.label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? AppColors.white : AppColors.getTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseAllSection(BuildContext context, List<Map<String, dynamic>> filteredRooms) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Browse by Room',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Text(
                      'Clear search',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Select a room category to explore furniture'
                  : 'Found ${filteredRooms.length} ${filteredRooms.length == 1 ? 'room' : 'rooms'} matching "$_searchQuery"',
              style: GoogleFonts.inter(
                color: AppColors.getSecondaryTextColor(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredRooms.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  return _buildRoomCard(context, room);
                },
              ),
            ),
          ],
        ),
      ),
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
                'No rooms found',
                style: GoogleFonts.inter(
                  color: AppColors.getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search terms',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.getSecondaryTextColor(context),
                  fontSize: 14,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _clearSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear Search'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Map<String, dynamic> room) {
    final filterOption = room['filterOption'] as FilterOption;

    final itemCount = _getItemCountForRoom(filterOption.value);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FurnitureCataloguePage(
              initialRoom: filterOption.value,
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
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
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
              color: AppColors.primaryPurple,
            ),
            const SizedBox(height: 12),
            Text(
              room['name'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            _isLoadingCounts
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryPurple,
              ),
            )
                : Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}