import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/pages/home_page.dart';
import 'views/pages/forgot_password_page.dart';
import 'views/pages/logout_page.dart';
import 'views/pages/catalogue_item_page.dart';
import 'views/pages/catalogue_page.dart';
import 'views/pages/my_likes_page.dart';
import 'views/pages/my_projects_page.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/help_page.dart';
import 'views/pages/edit_profile_page.dart';
import 'views/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomantic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F4FC),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),

        // Side menu routes
        '/catalogue': (context) => const CataloguePage(),
        '/likes': (context) => const LikesPage(),
        '/projects': (context) => const ProjectsPage(),
        '/settings': (context) => const SettingsPage(),
        '/help': (context) => const HelpPage(),
        '/edit_profile': (context) => const EditProfilePage(),

        // My assigned pages
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/logout': (context) => const LogoutPage(),
        '/catalogue_item': (context) => const CatalogueItemPage(),

        // Bottom navigation routes
        '/ar_view': (context) => const PlaceholderWidget(title: 'AR View'),
        '/cart': (context) => const PlaceholderWidget(title: 'Cart'),
        '/favorites': (context) => const LikesPage(),
        '/profile': (context) => const EditProfilePage(),
      },
      // Handle unknown routes gracefully
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Page not found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The page "${settings.name}" does not exist.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false
                      );
                    },
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Placeholder widget for unimplemented pages
class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF14213D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF2F4FC),
        foregroundColor: const Color(0xFF14213D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF14213D)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getPlaceholderIcon(title),
              size: 80,
              color: const Color(0xFF963CF1),
            ),
            const SizedBox(height: 20),
            Text(
              '$title - Coming Soon',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF14213D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This page is under development and will be available soon.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF963CF1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlaceholderIcon(String title) {
    switch (title.toLowerCase()) {
      case 'ar view':
        return Icons.view_in_ar;
      case 'cart':
        return Icons.shopping_cart;
      case 'search':
        return Icons.search;
      default:
        return Icons.construction;
    }
  }
}