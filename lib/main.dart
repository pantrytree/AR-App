import 'package:flutter/material.dart';
import 'views/pages/camera_page.dart';
import 'views/pages/catalogue_item_page.dart';
import 'views/pages/catalogue_page.dart';
import 'views/pages/edit_profile_page.dart';
import 'views/pages/forgot_password_page.dart';
import 'views/pages/help_page.dart';
import 'views/pages/home_page.dart';
import 'views/pages/login_page.dart';
import 'views/pages/my_likes_page.dart';
import 'views/pages/my_projects_page.dart';
import 'views/pages/settings_page.dart';
import 'views/pages/sign_up_page.dart';
import 'views/pages/splash_screen_page.dart';
import 'views/pages/splash_screen_2_page.dart';
import 'utils/colors.dart';


void main() {
  runApp(RoomanticApp());
}

class RoomanticApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roomantics',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreenPage(),
        '/splash2': (context) => SplashScreen2Page(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/camera-page': (context) => CameraPage(),
        '/catalogue-page': (context) => CataloguePage(),
        '/edit-profile': (context) => EditProfilePage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/help-page': (context) => HelpPage(),
        '/home-page': (context) => HomePage(),
       // '/logout-page': (context) => LogoutPage(),
        '/my-likes-page': (context) => MyLikesPage(),
        '/my-projects-page': (context) => MyProjectsPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
