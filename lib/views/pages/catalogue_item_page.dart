import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../../utils/text_components.dart';
import '../../theme/theme.dart';

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
  String _productTitle = "Queen Bed";
  String _productDimensions = "80×80 cm";
  String _productDescription = "Custom-made, handcrafted furniture designed to fit your unique style and space.";
  bool _isFavorite = false;

  final List<Map<String, String>> _relatedItems = [
    {"title": "Bedside Table", "dimensions": "30×60 cm", "id": "1"},
    {"title": "Wardrobe", "dimensions": "120×200 cm", "id": "2"},
    {"title": "Dresser", "dimensions": "40×80 cm", "id": "3"},
  ];

  void _openInAR() {
    print("Opening in AR - navigating to camera page");
    Navigator.pushNamed(context, '/camera_page');
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    print("${_isFavorite ? 'Added' : 'Removed'} from favorites");
  }

  void _navigateToRelatedItem(String productId) {
    Navigator.pushNamed(context, '/catalogue_item', arguments: {'productId': productId});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          appBar: AppBar(
            title: Text(
              "Product Details",
              style: TextStyle(
                color: AppColors.getAppBarForeground(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.getAppBarBackground(context),
            foregroundColor: AppColors.getAppBarForeground(context),
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.getAppBarForeground(context)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Title and Dimensions
                Text(
                  _productTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _productDimensions,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Product Image
                Container(
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
                  child: Icon(
                    Icons.photo,
                    size: 60,
                    color: AppColors.getPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Product Description
                Text(
                  _productDescription,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextColor(context),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                // Action Buttons (Open in AR, Add to Favorites)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openInAR,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getPrimaryColor(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Open in AR"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 30,
                        color: _isFavorite ? AppColors.likesHeart : AppColors.getPrimaryColor(context),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.getCardBackground(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Related Items Section
                Text(
                  "More to explore",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 16),

                // Related Items
                ..._relatedItems.map((item) =>
                    _buildRelatedItem(
                        context,
                        item["title"]!,
                        item["dimensions"]!,
                        item["id"]!
                    )
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedItem(BuildContext context, String title, String dimensions, String productId) {
    return GestureDetector(
      onTap: () => _navigateToRelatedItem(productId),
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
            // Item icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple, // Keep brand color for icons
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chair,
                color: AppColors.getPrimaryColor(context),
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
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  Text(
                    dimensions,
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
}