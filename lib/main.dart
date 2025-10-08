import 'package:flutter/material.dart';
import 'views/settings_page.dart';
import 'views/camera_page.dart';
import 'views/catalogue_page.dart';

final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

void main() {
  runApp(ValueListenableBuilder<bool>(
    valueListenable: darkModeNotifier,
    builder: (context, isDarkMode, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        home: const MainNavigation(),
      );
    },
  ));
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    CameraPage(),
    CataloguePage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Catalogue'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
