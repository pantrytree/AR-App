import 'package:flutter/material.dart';
import 'views/home_page.dart';
import 'views/catalogue_item_page.dart';
import 'views/forgot_password_page.dart';
import 'views/logout_page.dart';
import 'utils/colors.dart';
import 'utils/text_components.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TextComponents.appTitle,
      theme: ThemeData(
        primaryColor: AppColors.primaryPurple,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(userName: null), // Backend will provide this
        '/catalogue': (context) => _buildPlaceholderPage("Catalogue Page"),
        '/catalogue_item': (context) => const CatalogueItemPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/logout': (context) => const LogoutPage(),
        '/likes': (context) => _buildPlaceholderPage(TextComponents.menuLikes),
        '/projects': (context) => _buildPlaceholderPage(TextComponents.menuProjects),
        '/settings': (context) => _buildPlaceholderPage(TextComponents.menuSettings),
        '/help': (context) => _buildPlaceholderPage(TextComponents.menuHelp),
        '/edit_profile': (context) => _buildPlaceholderPage(TextComponents.menuEditProfile),
        '/sign_up': (context) => _buildPlaceholderPage("Sign Up Page"),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  static Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}