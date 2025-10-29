import 'package:Roomantics/services/auth_service.dart';
import 'package:Roomantics/services/cloudinary_service.dart';
import 'package:Roomantics/services/favorites_service.dart';
import 'package:Roomantics/services/furniture_service.dart';
import 'package:Roomantics/services/project_service.dart';
import 'package:Roomantics/services/room_service.dart';
import 'package:Roomantics/viewmodels/change_password_viewmodel.dart';
import 'package:Roomantics/viewmodels/guides_page_viewmodel.dart';
import 'package:Roomantics/viewmodels/notifications_viewmodel.dart';
import 'package:Roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/views/pages/about_page.dart';
import 'package:Roomantics/views/pages/active_sessions_page.dart';
import 'package:Roomantics/views/pages/change_passwords_page.dart';
import 'package:Roomantics/views/pages/furniture_catalogue_page.dart';
import 'package:Roomantics/views/pages/language_page.dart';
import 'package:Roomantics/views/pages/notifications_page.dart';
import 'package:Roomantics/views/pages/privacy_policy_page.dart';
import 'package:Roomantics/views/pages/profile_page.dart';
import 'package:Roomantics/views/pages/roomielab_page.dart';
import 'package:Roomantics/views/pages/roomielab_screen.dart';
import 'package:Roomantics/views/pages/terms_of_service_page.dart';
import 'package:Roomantics/views/pages/two_factor_auth_page.dart';
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

// Import all ViewModels
import 'viewmodels/camera_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/side_menu_viewmodel.dart';
import 'viewmodels/forgot_password_viewmodel.dart';
import 'viewmodels/logout_viewmodel.dart';
import 'viewmodels/my_likes_page_viewmodel.dart';
import 'viewmodels/help_page_viewmodel.dart';
import 'viewmodels/edit_profile_viewmodel.dart';
import 'viewmodels/profile_page_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/sign_up_viewmodel.dart';
import 'theme/theme.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and ThemeManager
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.initialize();

  runApp(MyApp(themeManager: themeManager));
}

class NoOpHeroController extends NavigatorObserver {
}

class MyApp extends StatelessWidget {
  final ThemeManager? themeManager;

  const MyApp({super.key, this.themeManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<CloudinaryService>(create: (_) => CloudinaryService()),
        Provider<FavoritesService>(create: (_) => FavoritesService()),
        Provider<FurnitureService>(create: (_) => FurnitureService()),
        Provider<ProjectService>(create: (_) => ProjectService()),
        Provider<RoomService>(create: (_) => RoomService()),

        // ViewModels
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            furnitureService: context.read<FurnitureService>(),
            roomService: context.read<RoomService>(),
            projectService: context.read<ProjectService>(),
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => GuidesPageViewModel()),
        ChangeNotifierProvider(create: (_) => SideMenuViewModel()),
        ChangeNotifierProvider(create: (_) => CameraViewModel()),
        ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
        ChangeNotifierProvider(create: (_) => RoomieLabViewModel()),
        ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => AccountHubViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => LogoutViewModel()),
        ChangeNotifierProvider(create: (_) => ChangePasswordViewModel()),

        // Theme Manager
        if (themeManager != null)
          ChangeNotifierProvider.value(value: themeManager!)
        else
          ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            navigatorObservers: [
            ],
            debugShowCheckedModeBanner: false,
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
              '/splash': (context) => SplashScreenPage(),
              '/splash2': (context) => SplashScreen2Page(),
              '/login': (context) => LoginPage(),
              '/signup': (context) => SignUpPage(),
              '/forgot-password': (context) => const ForgotPasswordPage(),
              '/': (context) => const HomePage(),
              '/home': (context) => const HomePage(),
              '/catalogue': (context) => const CataloguePage(),
              '/furniture-catalogue': (context) => const FurnitureCataloguePage(),
              '/my-likes': (context) => const MyLikesPage(),
              '/project': (context) => const RoomieLabPage(),
              '/roomieLab': (context) => const RoomieLabScreen(),
              '/settings': (context) => const SettingsPage(),
              '/help': (context) => const HelpPage(),
              '/account-hub': (context) => const AccountHubPage(),
              '/edit-profile': (context) => const EditProfilePage(),
              '/logout': (context) => const LogoutPage(),
              '/catalogue-item': (context) => const CatalogueItemPage(),
              '/camera-page': (context) =>  CameraPage(),
              '/language': (context) => const LanguagePage(),
              '/notifications': (context) => const NotificationsPage(),
              '/about': (context) => const AboutPage(),
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
