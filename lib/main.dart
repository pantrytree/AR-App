import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:roomantics/views/pages/about_page.dart';
import 'package:roomantics/views/pages/active_sessions_page.dart';
import 'package:roomantics/views/pages/change_passwords_page.dart';
import 'package:roomantics/views/pages/language_page.dart';
import 'package:roomantics/views/pages/notifications_page.dart';
import 'package:roomantics/views/pages/privacy_policy_page.dart';
import 'package:roomantics/views/pages/roomielab_screen.dart';
import 'package:roomantics/views/pages/terms_of_service_page.dart';
import 'package:roomantics/views/pages/two_factor_auth_page.dart';
import 'firebase_options.dart';

// Import all pages
import 'views/pages/home_page.dart';
import 'views/pages/forgot_password_page.dart';
import 'views/pages/logout_page.dart';
import 'views/pages/catalogue_item_page.dart';
import 'views/pages/catalogue_page.dart';
import 'views/pages/my_likes_page.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/help_page.dart';
import 'views/pages/edit_profile_page.dart';
import 'views/pages/login_page.dart';
import 'views/pages/camera_page.dart';
import 'views/pages/splash_screen_page.dart';
import 'views/pages/splash_screen_2_page.dart';
import 'views/pages/sign_up_page.dart';
import 'views/pages/furniture_catalogue_page.dart';
import 'views/pages/profile_page.dart';

// Import all ViewModels
import 'viewmodels/camera_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/side_menu_viewmodel.dart';
import 'viewmodels/forgot_password_viewmodel.dart';
import 'viewmodels/logout_viewmodel.dart';
import 'viewmodels/my_likes_page_viewmodel.dart';
import 'viewmodels/help_page_viewmodel.dart';
import 'viewmodels/edit_profile_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/sign_up_viewmodel.dart';
import 'viewmodels/profile_page_viewmodel.dart';

// Import services
import 'services/likes_service.dart';

import 'theme/theme.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and ThemeManager
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.initialize();

  runApp(MyApp(themeManager: themeManager));
}

class MyApp extends StatelessWidget {
  final ThemeManager? themeManager;

  const MyApp({super.key, this.themeManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers for all pages that use ViewModels
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SideMenuViewModel(userName: "Bulelwa")),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
        ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),

        // Add LikesService for shared liked items management
        ChangeNotifierProvider(create: (_) => LikesService()),

        // Use provided themeManager or create a new one
        if (themeManager != null)
          ChangeNotifierProvider.value(value: themeManager!)
        else
          ChangeNotifierProvider(create: (_) => ThemeManager()),
        // Login and SignUp ViewModels are created within their pages
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Roomantic',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.secondaryBackground,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.secondaryBackground,
                foregroundColor: AppColors.primaryDarkBlue,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.primaryDarkBlue),
              ),
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryPurple,
                secondary: AppColors.primaryLightPurple,
                background: AppColors.secondaryBackground,
                surface: AppColors.white,
                onBackground: AppColors.primaryDarkBlue,
                onSurface: AppColors.primaryDarkBlue,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.purple,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.primaryDarkBlue,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: AppColors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.white),
              ),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryPurple,
                secondary: AppColors.primaryLightPurple,
                background: AppColors.primaryDarkBlue,
                surface: AppColors.primaryDarkBlue,
                onBackground: AppColors.white,
                onSurface: AppColors.white,
              ),
            ),
            themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              // Splash screens
              '/splash': (context) => SplashScreenPage(),
              '/splash2': (context) => SplashScreen2Page(),

              // Authentication routes
              '/login': (context) => LoginPage(),
              '/signup': (context) => SignUpPage(),
              '/forgot_password': (context) => ChangeNotifierProvider(
                create: (_) => ForgotPasswordViewModel(),
                child: const ForgotPasswordPage(),
              ),

              // Main app routes
              '/': (context) => const HomePage(),
              '/home': (context) => const HomePage(),

              // Side menu routes
              '/catalogue': (context) => const CataloguePage(),
              '/my_likes_page': (context) => const MyLikesPage(),
              '/settings': (context) => const SettingsPage(),
              '/help': (context) => const HelpPage(),
              '/edit_profile': (context) => const EditProfilePage(),

              // Other pages
              '/logout': (context) => ChangeNotifierProvider(
                create: (_) => LogoutViewModel(),
                child: const LogoutPage(),
              ),
              '/catalogue_item': (context) => const CatalogueItemPage(),
              '/camera_page': (context) => CameraPage(),
              '/roomielab': (context) => RoomieLabScreen(), // Full AR studio
              '/language': (context) => const LanguagePage(),
              '/notifications': (context) => const NotificationsPage(),
              '/about': (context) => const AboutPage(),
              '/furniture-catalogue': (context) => const FurnitureCataloguePage(),
              '/profile': (context) => const AccountHubPage(),


              // Settings navigation routes (for SettingsViewModel)
              '/language': (context) => LanguagePage(),
              '/notifications': (context) => NotificationsPage(),
              '/about': (context) => AboutPage(),
              '/help': (context) => HelpPage(),
              '/logout': (context) => LogoutPage(),
              '/change-password': (context) => ChangePasswordPage(),
              '/two-factor-auth': (context) => TwoFactorAuthPage(),
              '/active-sessions': (context) => ActiveSessionsPage(),
              '/privacy-policy': (context) => PrivacyPolicyPage(),
              '/terms-of-service': (context) => TermsOfServicePage(),
              '/forgot_password': (context) => const ForgotPasswordPage(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      'Page Not Found',
                      style: TextStyle(
                        color: AppColors.getAppBarForeground(context),
                      ),
                    ),
                    backgroundColor: AppColors.getAppBarBackground(context),
                    foregroundColor: AppColors.getAppBarForeground(context),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.getSecondaryTextColor(context)
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Page not found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The page "${settings.name}" does not exist.',
                          style: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
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
        },
      ),
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
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.getAppBarForeground(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.getAppBarForeground(context)),
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
              color: AppColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 20),
            Text(
              '$title - Coming Soon',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This page is under development and will be available soon.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(context),
                foregroundColor: AppColors.white,
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
      case 'camera/ar view':
        return Icons.camera_alt;
      case 'search':
        return Icons.search;
      case 'language settings':
        return Icons.language;
      case 'notifications':
        return Icons.notifications;
      case 'about app':
        return Icons.info;
      default:
        return Icons.construction;
    }
  }
}