import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:roomantics/main.dart';
import 'package:roomantics/theme/theme.dart';
import 'package:roomantics/viewmodels/home_viewmodel.dart';
import 'package:roomantics/viewmodels/side_menu_viewmodel.dart';
import 'package:roomantics/viewmodels/camera_viewmodel.dart';
import 'package:roomantics/viewmodels/my_likes_page_viewmodel.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/viewmodels/help_page_viewmodel.dart';
import 'package:roomantics/viewmodels/edit_profile_viewmodel.dart';
import 'package:roomantics/viewmodels/settings_viewmodel.dart';
import 'package:roomantics/views/pages/catalogue_page.dart';
import 'package:roomantics/views/pages/home_page.dart';
import 'package:roomantics/views/pages/my_likes_page.dart';
import 'package:roomantics/views/pages/settings_page.dart';
import 'package:roomantics/views/pages/splash_screen_page.dart';

void main() {
  group('Roomantic App Tests', () {
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      // Create a ThemeManager instance
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(MyApp(themeManager: themeManager));
      expect(find.byType(SplashScreenPage), findsOneWidget);
    });

    testWidgets('Home page displays correctly', (WidgetTester tester) async {
      // Create a ThemeManager instance
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => HomeViewModel()),
            ChangeNotifierProvider(create: (_) => SideMenuViewModel(userName: "Test User")),
            ChangeNotifierProvider(create: (_) => CameraViewModel()),
            ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
            ChangeNotifierProvider(create: (_) => RoomieLabViewModel()),
            ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
            ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
            ChangeNotifierProvider(create: (_) => SettingsViewModel()),
            ChangeNotifierProvider.value(value: themeManager),
          ],
          child: MaterialApp(home: HomePage()),
        ),
      );
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Catalogue page loads', (WidgetTester tester) async {
      // Create a ThemeManager instance
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider.value(value: themeManager)],
          child: MaterialApp(home: CataloguePage()),
        ),
      );
      expect(find.byType(CataloguePage), findsOneWidget);
    });

    testWidgets('My Likes page loads', (WidgetTester tester) async {
      // Create a ThemeManager instance
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeManager),
            ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
          ],
          child: MaterialApp(home: MyLikesPage()),
        ),
      );
      expect(find.byType(MyLikesPage), findsOneWidget);
    });

    testWidgets('Settings page loads', (WidgetTester tester) async {
      // Create a ThemeManager instance
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeManager),
            ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ],
          child: MaterialApp(home: SettingsPage()),
        ),
      );
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('Unknown route shows error page', (WidgetTester tester) async {
      // Create a ThemeManager instance
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(MyApp(themeManager: themeManager));

      // Navigate to unknown route
      final BuildContext context = tester.element(find.byType(MaterialApp));
      Navigator.of(context).pushNamed('/unknown-route');

      await tester.pumpAndSettle();
      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('ThemeManager provides dark/light theme', (WidgetTester tester) async {
      final themeManager = ThemeManager();
      await themeManager.initialize();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeManager,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final themeManager = Provider.of<ThemeManager>(context);
                return Text(themeManager.isDarkMode ? 'Dark' : 'Light');
              },
            ),
          ),
        ),
      );

      expect(find.text('Light'), findsOneWidget);
    });
  });
}