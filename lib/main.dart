import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:roomantics/views/pages/about_page.dart';
import 'package:roomantics/views/pages/active_sessions_page.dart';
import 'package:roomantics/views/pages/change_passwords_page.dart';
import 'package:roomantics/views/pages/language_page.dart';
import 'package:roomantics/views/pages/notifications_page.dart';
import 'package:roomantics/views/pages/privacy_policy_page.dart';
import 'package:roomantics/views/pages/terms_of_service_page.dart';
import 'package:roomantics/views/pages/two_factor_auth_page.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/views/pages/roomielab_page.dart';

import 'firebase_options.dart';

// Import all pages
import 'views/pages/home_page.dart';
import 'views/pages/forgot_password_page.dart';
import 'views/pages/logout_page.dart';
import 'views/pages/catalogue_item_page.dart';
import 'views/pages/catalogue_page.dart';
import 'views/pages/my_likes_page.dart';
import 'views/pages/roomielab_page.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/help_page.dart';
import 'views/pages/edit_profile_page.dart';
import 'views/pages/login_page.dart';
import 'views/pages/camera_page.dart';
import 'views/pages/splash_screen_page.dart';
import 'views/pages/splash_screen_2_page.dart';
import 'views/pages/sign_up_page.dart';

// Import all ViewModels
import 'viewmodels/camera_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/side_menu_viewmodel.dart';
import 'viewmodels/forgot_password_viewmodel.dart';
import 'viewmodels/logout_viewmodel.dart';
import 'viewmodels/my_likes_page_viewmodel.dart';
import 'viewmodels/roomielab_viewmodel.dart';
import 'viewmodels/help_page_viewmodel.dart';
import 'viewmodels/edit_profile_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'theme/theme.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.initialize();

  runApp(MyApp(themeManager: themeManager));
}

class MyApp extends StatelessWidget {
  final ThemeManager themeManager;

  const MyApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers for all pages that use ViewModels
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SideMenuViewModel(userName: "Bulelwa")),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
        ChangeNotifierProvider(create: (_) => RoomieLabViewModel()),
        ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        // Use provided themeManager
        ChangeNotifierProvider.value(value: themeManager),
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
                child: ForgotPasswordPage(),
              ),

              // Main app routes
              '/': (context) => HomePage(),
              '/home': (context) => HomePage(),

              // Side menu routes
              '/catalogue': (context) => CataloguePage(),
              '/likes': (context) => MyLikesPage(),
              '/roomielab': (context) => RoomieLabPage(),
              '/settings': (context) => SettingsPage(),
              '/help': (context) => HelpPage(),
              '/edit_profile': (context) => EditProfilePage(),

              // Other pages
              '/logout': (context) => ChangeNotifierProvider(
                create: (_) => LogoutViewModel(),
                child: LogoutPage(),
              ),
              '/catalogue_item': (context) => CatalogueItemPage(furnitureId: 'default_id', productIdproductId: null,),
              '/camera_page': (context) => CameraPage(),
              '/language': (context) => LanguagePage(),
              '/notifications': (context) => NotificationsPage(),
              '/about': (context) => AboutPage(),



              // Settings navigation routes
              '/change-password': (context) => ChangePasswordPage(),
              '/two-factor-auth': (context) => TwoFactorAuthPage(),
              '/active-sessions': (context) => ActiveSessionsPage(),
              '/privacy-policy': (context) => PrivacyPolicyPage(),
              '/terms-of-service': (context) => TermsOfServicePage(),
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
                          color: AppColors.getSecondaryTextColor(context),
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
                              context,
                              '/home',
                                  (route) => false,
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
        },
      ),
    );
  }
}