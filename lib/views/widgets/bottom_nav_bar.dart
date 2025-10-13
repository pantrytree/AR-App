import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      backgroundColor: AppColors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: AppColors.black),
          label: '',
        ),
      ],
      selectedItemColor: AppColors.likesHeart,
      unselectedItemColor: AppColors.black,
      onTap: onTap,
    );
  }
}
