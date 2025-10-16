import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'viewmodels/help_page_viewmodel.dart';
import 'viewmodels/my_likes_page_viewmodel.dart';
import 'viewmodels/my_projects_viewmodel.dart';
import 'viewmodels/edit_profile_viewmodel.dart';

// Pages
import 'views/pages/help_page.dart';
import 'views/pages/my_likes_page.dart';
import 'views/pages/my_projects_page.dart';
import 'views/pages/edit_profile_page.dart';


/// Entry point of the app
void main() {
  runApp(const MyApp());
}

/// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers for different pages
        ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
        ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
        ChangeNotifierProvider(create: (_) => MyProjectsViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Roomantics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Inter',
        ),
        // Set initial page here - for me
        home: const HelpPage(),
        // Route names later for navigation
        routes: {
          '/help': (_) => const HelpPage(),
          '/likes': (_) => const MyLikesPage(),
          '/projects': (_) => const MyProjectsPage(),
          '/profile': (_) => const EditProfilePage(),
        },
      ),
    );
  }
}
