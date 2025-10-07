import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';
import '/viewmodels/catalogue_item_viewmodel.dart';

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
  late final CatalogueItemViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CatalogueItemViewModel(productId: widget.productId);
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() => setState(() {});

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextComponents.cataloguePageTitle),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Title and Dimensions
            Text(
              _viewModel.productTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.productDimensions,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 20),

            // Product Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.photo,
                size: 60,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 20),

            // Product Description
            Text(
              _viewModel.productDescription,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons (Add to Cart, Add to Favorites)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _viewModel.addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Add to Cart"),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _viewModel.toggleFavorite,
                  icon: Icon(
                    _viewModel.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 30,
                    color: _viewModel.isFavorite ? Colors.pink : AppColors.textLight,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Related Items Section
            Text(
              TextComponents.moreToExploreTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Related Items
            ..._viewModel.relatedItems.map((item) =>
                _buildRelatedItem(
                    item["title"]!,
                    item["dimensions"]!,
                    item["id"]!,
                    context
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedItem(String title, String dimensions, String productId, BuildContext context) {
    return GestureDetector(
      onTap: () => _viewModel.navigateToRelatedItem(context, productId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Item icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chair,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    dimensions,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}