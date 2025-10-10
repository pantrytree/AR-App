import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/camera_page.dart';
import 'views/pages/catalogue_page.dart';
import 'views/widgets/bottom_nav_bar.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/catalogue_viewmodel.dart';
import 'utils/colors.dart';
import 'utils/theme.dart'; // ✅ CORRECT IMPORT

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()), // ✅ CORRECT CLASS NAME
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => CatalogueViewModel()),
      ],
      child: Consumer<ThemeManager>( // ✅ CORRECT CLASS NAME
        builder: (context, themeManager, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primaryPurple,
              scaffoldBackgroundColor: AppColors.secondaryBackground,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.secondaryBackground,
                foregroundColor: AppColors.primaryDarkBlue,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              primaryColor: AppColors.primaryPurple,
              scaffoldBackgroundColor: AppColors.primaryDarkBlue,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
            ),
            themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigation(),
            routes: {
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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PlaceholderPage(title: 'Home'),
    const PlaceholderPage(title: 'Favorites'),
    const CameraPage(),
    const CataloguePage(),
    const SettingsPage(),
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            const Text('This page is under development'),
          ],
        ),
      ),
    );
  }
}