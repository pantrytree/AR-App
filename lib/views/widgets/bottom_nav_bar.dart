import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home
                  _buildNavItem(
                    context,
                    icon: Icons.home,
                    label: 'Home',
                    index: 0,
                  ),

                  // Likes/Favorites
                  _buildNavItem(
                    context,
                    icon: Icons.favorite,
                    label: 'Likes',
                    index: 1,
                  ),

                  // Camera/AR
                  _buildNavItem(
                    context,
                    icon: Icons.camera_alt,
                    label: 'AR View',
                    index: 2,
                  ),

                  // Catalogue/Shopping
                  _buildNavItem(
                    context,
                    icon: Icons.shopping_bag,
                    label: 'Catalogue',
                    index: 3,
                  ),

                  // Profile
                  _buildNavItem(
                    context,
                    icon: Icons.person,
                    label: 'Profile',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.getPrimaryColor(context)
                  : AppColors.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.getPrimaryColor(context)
                    : AppColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}