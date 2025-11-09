// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_item.dart';
import '../../viewmodels/catalogue_viewmodel.dart';
import '../../views/widgets/bottom_nav_bar.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';
import '../../utils/theme.dart';
import 'catalogue_item_page.dart';

// Main catalogue page displaying furniture items in a grid layout
// Supports search, category filtering, and theme-aware styling
class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ChangeNotifierProvider(
          create: (_) => CatalogueViewModel(),
          child: const _CataloguePageBody(),
        );
      },
    );
  }
}

// Private stateful widget body for the catalogue page
// Handles search functionality and item navigation
class _CataloguePageBody extends StatefulWidget {
  const _CataloguePageBody();

  @override
  State<_CataloguePageBody> createState() => _CataloguePageBodyState();
}

class _CataloguePageBodyState extends State<_CataloguePageBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Navigates to the detailed item page when a product card is tapped
  void _openItem(BuildContext context, FurnitureItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogueItemPage(productId: item.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getAppBarBackground(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          TextComponents.cataloguePageTitle,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.getAppBarForeground(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(context, vm), // Header with search and title
          const SizedBox(height: 10),
          _buildCategoryChips(context, vm), // Category filter chips
          const SizedBox(height: 10),
          // Item count display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${vm.filteredItems.length} items found',
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Main content grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildGrid(vm),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the header section with title, subtitle, and search bar
  Widget _buildHeader(BuildContext context, CatalogueViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.getPrimaryColor(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextComponents.catalogueHeaderTitle,
            style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20
            ),
          ),
          const SizedBox(height: 6),
          Text(
            TextComponents.catalogueHeaderSubtitle,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 13
            ),
          ),
          const SizedBox(height: 12),
          // Search input field
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.getTextFieldBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => vm.setSearchQuery(v), // Update search filter
              style: TextStyle(color: AppColors.getTextColor(context)),
              decoration: InputDecoration(
                hintText: TextComponents.searchHint,
                hintStyle: TextStyle(color: AppColors.getSecondaryTextColor(context)),
                prefixIcon: Icon(Icons.search, color: AppColors.getSecondaryTextColor(context)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds horizontal scrollable category filter chips
  Widget _buildCategoryChips(BuildContext context, CatalogueViewModel vm) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: vm.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final category = vm.categories[idx];
          final selected = category == vm.selectedCategory;
          return ChoiceChip(
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            label: Text(
              category,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.getTextColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            selectedColor: AppColors.getPrimaryColor(context),
            backgroundColor: AppColors.getCategoryTabUnselected(context),
            side: BorderSide(color: AppColors.getBorderColor(context)),
            onSelected: (_) => vm.selectCategory(category), // Update category filter
          );
        },
      ),
    );
  }

  // Builds the main product grid or empty state message
  Widget _buildGrid(CatalogueViewModel vm) {
    final items = vm.filteredItems;
    if (items.isEmpty) {
      return Center(
        child: Text(
            TextComponents.noItemsFound,
            style: TextStyle(color: AppColors.getSecondaryTextColor(context))
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];
        return _productCard(context, it);
      },
    );
  }

  // Builds individual product card with image, details, and favorite button
  Widget _productCard(BuildContext context, FurnitureItem item) {
    return Card(
      elevation: 2,
      color: AppColors.getCardBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openItem(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with loading and error states
            SizedBox(
              height: 100,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 100,
                      color: AppColors.lightGrey,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    if (kDebugMode) {
                      debugPrint('Image failed to load: ${item.imageUrl}');
                      debugPrint('Error: $error');
                    }
                    return Container(
                      height: 100,
                      color: AppColors.lightGrey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              Icons.broken_image,
                              color: AppColors.getSecondaryTextColor(context),
                              size: 30
                          ),
                          const SizedBox(height: 4),
                          Text(
                              'No image',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.getSecondaryTextColor(context)
                              )
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Product details section
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                      "${item.dimensions['width']} x ${item.dimensions['height']} ${item.dimensions['unit']}",
                      style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Price and favorite button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R${item.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPrimaryColor(context),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to favorites')),
                          );
                        },
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
}
