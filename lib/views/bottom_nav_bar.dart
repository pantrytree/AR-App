import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class BottomNavBar extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;

  const BottomNavBar({
    super.key,
    this.onTabSelected,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (widget.onTabSelected != null) {
      widget.onTabSelected!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryPurple,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.60),
      selectedFontSize: 14,
      unselectedFontSize: 14,
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: TextComponents.navHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: TextComponents.navArView,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: TextComponents.navCart,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: TextComponents.navFavorites,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: TextComponents.navProfile,
        ),
      ],
    );
  }
}