// Roomantics - Main Application Entry Point
//
// PURPOSE: Root of the Flutter application, sets up providers and navigation
//
// ARCHITECTURE:
// - MultiProvider for state management across the app
// - ThemeManager for dark/light mode theming
// - MainNavigation for bottom tab navigation
//
// BACKEND INTEGRATION READY:
// - All ViewModels are set up and ready for API integration
// - Route structure defined for future feature pages
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/camera_page.dart';
import 'views/pages/catalogue_page.dart';
import 'views/pages/home_page.dart';
import 'views/widgets/bottom_nav_bar.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/camera_viewmodel.dart';
import 'viewmodels/main_viewmodel.dart';
import 'viewmodels/catalogue_viewmodel.dart';
import 'utils/colors.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => CatalogueViewModel()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          print('🎨 Theme changed: ${themeManager.isDarkMode ? 'Dark' : 'Light'}');
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primaryPurple,
              scaffoldBackgroundColor: AppColors.secondaryBackground,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.secondaryBackground,
                foregroundColor: AppColors.primaryDarkBlue,
                elevation: 0,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              primaryColor: AppColors.primaryPurple,
              scaffoldBackgroundColor: AppColors.primaryDarkBlue,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
              useMaterial3: true,
            ),
            themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigation(),
            routes: {
              // TODO: Replace placeholders with actual pages when developed
              '/language': (context) => const PlaceholderPage(title: 'Language Settings'),
              '/notifications': (context) => const PlaceholderPage(title: 'Notifications'),
              '/about': (context) => const PlaceholderPage(title: 'About Application'),
              '/help': (context) => const PlaceholderPage(title: 'Help & FAQ'),
              '/profile': (context) => const PlaceholderPage(title: 'Profile'),
            },
          );
        },
      ),
    );
  }
}
// MainNavigation - Bottom Navigation Wrapper
//
// PURPOSE: Handles main app navigation between 5 primary sections
//
// NAVIGATION STRUCTURE:
// - Index 0: Home (Dashboard)
// - Index 1: Favorites (Future development)
// - Index 2: Camera (AR Furniture Placement)
// - Index 3: Catalogue (Product Browsing)
// - Index 4: Settings (App Preferences)
//
// STATE: Manages current tab index and page switching
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(), // Main dashboard - basic placeholder
    const PlaceholderPage(title: 'Favorites'), // Future: My Likes/Favorites
    const CameraPage(), //AR Camera with furniture placement
    const CataloguePage(), // Product catalog with search/filter
    const SettingsPage(), // App settings and user preferences
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
// PlaceholderPage - Development Placeholder
//
// PURPOSE: Temporary page for features under development
// USAGE: Used for Favorites, Language, Notifications, etc. until developed

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20),
            const Text('This page is under development'),
          ],
        ),
      ),
    );
  }
}