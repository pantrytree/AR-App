// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/catalogue_viewmodel.dart';
import '../../utils/colors.dart';
import '../../theme/theme.dart';
import 'catalogue_item_page.dart';

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

class _CataloguePageBody extends StatefulWidget {
  const _CataloguePageBody();

  @override
  State<_CataloguePageBody> createState() => _CataloguePageBodyState();
}

class _CataloguePageBodyState extends State<_CataloguePageBody> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _likedItems = {}; // Track liked items locally

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openItem(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogueItemPage(productId: item['id']),
      ),
    );
  }

  void _toggleLike(String itemId) {
    setState(() {
      if (_likedItems.contains(itemId)) {
        _likedItems.remove(itemId);
        // TODO: Remove from My Likes page via ViewModel
        _showSnackBar(context, 'Removed from likes');
      } else {
        _likedItems.add(itemId);
        // TODO: Add to My Likes page via ViewModel
        _showSnackBar(context, 'Added to likes');
      }
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CatalogueViewModel>();

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
          ),
          body: Column(
            children: [
              _buildHeader(context, vm),
              const SizedBox(height: 10),
              _buildCategoryChips(context, vm),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${vm.filteredItems.length} items found',
                      style: GoogleFonts.inter(
                        color: AppColors.getSecondaryTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
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
      },
    );
  }

  Widget _buildHeader(BuildContext context, CatalogueViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple, // Keep purple header in both themes
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Style',
            style: GoogleFonts.inter(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Discover perfect furniture for your space',
            style: GoogleFonts.inter(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => vm.setSearchQuery(v),
              style: GoogleFonts.inter(color: AppColors.primaryDarkBlue),
              decoration: InputDecoration(
                hintText: 'Search furniture...',
                hintStyle: GoogleFonts.inter(color: AppColors.mediumGrey),
                prefixIcon: Icon(Icons.search, color: AppColors.mediumGrey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, CatalogueViewModel vm) {
    final categories = ['All', 'Bedroom', 'Living Room', 'Office', 'Dining'];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final category = categories[idx];
          final selected = category == vm.selectedCategory;
          return GestureDetector(
            onTap: () => vm.selectCategory(category),
            child: Container(
              constraints: const BoxConstraints(minWidth: 70),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.getCategoryTabSelected(context)
                    : AppColors.getCategoryTabUnselected(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.getCategoryTabSelected(context)
                      : AppColors.getCategoryTabUnselected(context),
                ),
              ),
              child: Text(
                category,
                style: GoogleFonts.inter(
                  color: selected ? AppColors.white : AppColors.getTextColor(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(CatalogueViewModel vm) {
    final items = vm.filteredItems;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.getSecondaryTextColor(context)
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: GoogleFonts.inter(
                color: AppColors.getTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final it = items[index];
        return _productCard(context, it);
      },
    );
  }

  Widget _productCard(BuildContext context, Map<String, dynamic> item) {
    final isLiked = _likedItems.contains(item['id']);

    return Container(
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
      child: InkWell(
        onTap: () => _openItem(context, item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple, // Keep light purple for images
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Image or placeholder
                  item['imageUrl'] != null && item['imageUrl']!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      item['imageUrl']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(context);
                      },
                    ),
                  )
                      : _buildImagePlaceholder(context),

                  // Heart icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleLike(item['id']),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? AppColors.likesHeart : AppColors.getSecondaryTextColor(context),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Sample Furniture',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item['dimensions']?['width'] ?? 0} x ${item['dimensions']?['height'] ?? 0} ${item['dimensions']?['unit'] ?? 'cm'}",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.getSecondaryTextColor(context),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLightPurple, // Keep light purple for placeholders
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Icon(
            Icons.chair,
            size: 40,
            color: AppColors.primaryPurple // Keep purple icon
        ),
      ),
    );
  }
}