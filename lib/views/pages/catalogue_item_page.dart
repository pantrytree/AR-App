// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_item.dart';
import '../../viewmodels/catalogue_item_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';
import '../../utils/theme.dart';

class CatalogueItemPage extends StatelessWidget {
  final String itemId;

  const CatalogueItemPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ChangeNotifierProvider(
          create: (_) => CatalogueItemViewModel()..loadItem(itemId),
          child: const _CatalogueItemBody(),
        );
      },
    );
  }
}

class _CatalogueItemBody extends StatelessWidget {
  const _CatalogueItemBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CatalogueItemViewModel>();
    final item = viewModel.selectedItem;

    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.getPrimaryColor(context)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.getAppBarBackground(context),
        iconTheme: IconThemeData(
          color: AppColors.getAppBarForeground(context),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            color: AppColors.getAppBarForeground(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.lightGrey,
                    child: Icon(Icons.image_not_supported, size: 50, color: AppColors.getSecondaryTextColor(context)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(item.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.getTextColor(context))),
            const SizedBox(height: 8),
            Text(item.category, style: TextStyle(fontSize: 16, color: AppColors.getSecondaryTextColor(context))),
            const SizedBox(height: 16),
            Text(item.description, style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.getSecondaryTextColor(context))),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.straighten, size: 22, color: AppColors.getPrimaryColor(context)),
                const SizedBox(width: 8),
                Text("Dimensions: ${item.dimensions}", style: TextStyle(fontSize: 15, color: AppColors.getTextColor(context), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            Text("R${item.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.getPrimaryColor(context))),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to Favorites"))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getPrimaryColor(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.favorite_border, color: AppColors.white),
                    label: const Text("Add to Favorites", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AR View Coming Soon"))),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.getPrimaryColor(context), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(Icons.view_in_ar, color: AppColors.getPrimaryColor(context)),
                    label: Text("View in AR", style: TextStyle(color: AppColors.getPrimaryColor(context), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 8,
              children: item.tags.map((tag) => Chip(
                backgroundColor: AppColors.getCategoryTabSelected(context),
                label: Text(tag, style: TextStyle(color: AppColors.getTextColor(context), fontWeight: FontWeight.w500)),
              )).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}