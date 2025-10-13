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

  void _onViewModelChanged() {
    if (_viewModel.navigateToRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(
          context,
          _viewModel.navigateToRoute!,
          arguments: _viewModel.navigationArguments,
        ).then((_) => _viewModel.clearNavigation());
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          TextComponents.cataloguePageTitle,
          style: TextStyle(
            color: AppColors.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: AppColors.primaryDarkBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryDarkBlue),
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
                color: AppColors.primaryDarkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _viewModel.productDimensions,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Product Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                color: AppColors.primaryDarkBlue,
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
                    color: _viewModel.isFavorite ? Colors.pink : AppColors.primaryPurple,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white,
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
                color: AppColors.primaryDarkBlue,
              ),
            ),
            const SizedBox(height: 16),

            // Related Items
            ..._viewModel.relatedItems.map((item) =>
                _buildRelatedItem(
                    item["title"]!,
                    item["dimensions"]!,
                    item["id"]!
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedItem(String title, String dimensions, String productId) {
    return GestureDetector(
      onTap: () => _viewModel.navigateToRelatedItem(productId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
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
            // Item icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple,
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
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                  Text(
                    dimensions,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}