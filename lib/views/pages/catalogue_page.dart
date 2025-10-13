import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          TextComponents.menuCatalogue,
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
      body: const Center(
        child: Text('Catalogue Page - iyeza soon soon'),
      ),
    );
  }
}