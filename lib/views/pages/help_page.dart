import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          TextComponents.menuHelp,
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
        child: Text('Help Page - iyeza soon soon'),
      ),
    );
  }
}