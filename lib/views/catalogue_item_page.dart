import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class CatalogueItemPage extends StatelessWidget {
  final String? productId;

  const CatalogueItemPage({
    super.key,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    // needs backend
    return Scaffold(
      appBar: AppBar(
        title: Text(TextComponents.cataloguePageTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Title and Dimensions
            Text(
              "Queen Bed",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "80×80 cm",
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.photo,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Product Description
            Text(
              "Custom-made, handcrafted furniture designed to fit your unique style and space.",
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
                    onPressed: () {
                      // Backend: Add to cart functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Add to Cart"),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    // Backend: Add to favorites functionality
                  },
                  icon: Icon(Icons.favorite_border, size: 30),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
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
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Related Items
            _buildRelatedItem("Bedside Table", "30×60 cm", context),
            const SizedBox(height: 12),
            _buildRelatedItem("Wardrobe", "120×200 cm", context),
            const SizedBox(height: 12),
            _buildRelatedItem("Dresser", "40×80 cm", context),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedItem(String title, String dimensions, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to another product detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CatalogueItemPage(productId: "related_item_id"),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Item icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chair,
                color: AppColors.primary,
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