import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/help_page_viewmodel.dart';
import 'viewmodels/my_likes_page_viewmodel.dart';
import 'viewmodels/my_projects_viewmodel.dart';
import 'viewmodels/edit_profile_viewmodel.dart';
import '../views/help_page.dart';
import '../views/my_likes_page.dart';
import '../views/my_projects_page.dart';
import '../views/edit_profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
        ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
        ChangeNotifierProvider(create: (_) => MyProjectsViewModel()),
        ChangeNotifierProvider(create: (_) => MyProjectsViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Roomantics',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Inter',
        ),
        home: const EditProfilePage(),
      ),
    );
  }
}