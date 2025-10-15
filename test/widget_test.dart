import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Import your main app and dependencies
import 'package:roomantics/main.dart';
import 'package:roomantics/theme/theme.dart';
import 'package:roomantics/viewmodels/home_viewmodel.dart';
import 'package:roomantics/viewmodels/side_menu_viewmodel.dart';
import 'package:roomantics/viewmodels/camera_viewmodel.dart';
import 'package:roomantics/viewmodels/my_likes_page_viewmodel.dart';
import 'package:roomantics/viewmodels/my_projects_viewmodel.dart';
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
      // Build our app
      await tester.pumpWidget(const MyApp());

      // Verify the app starts with splash route
      expect(find.byType(SplashScreenPage), findsOneWidget);
    });

    testWidgets('Home page displays correctly', (WidgetTester tester) async {
      // Build our app directly with home page
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => HomeViewModel()),
            ChangeNotifierProvider(create: (_) => SideMenuViewModel(userName: "Test User")),
            ChangeNotifierProvider(create: (_) => CameraViewModel()),
            ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
            ChangeNotifierProvider(create: (_) => MyProjectsViewModel()),
            ChangeNotifierProvider(create: (_) => HelpPageViewModel()),
            ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
            ChangeNotifierProvider(create: (_) => SettingsViewModel()),
            ChangeNotifierProvider(create: (_) => ThemeManager()),
          ],
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Verify home page elements are present
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Theme switching works', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const MyApp());

      // Get the theme manager from Provider
      final themeManager = tester.widget<Consumer<ThemeManager>>(find.byType(Consumer<ThemeManager>)).builder(
        tester.element(find.byType(Consumer<ThemeManager>)),
        ThemeManager(),
        null,
      ) as ThemeManager;

      // Verify initial state (should be light mode by default)
      expect(themeManager.isDarkMode, false);

      // Switch to dark mode
      themeManager.toggleTheme(true);
      await tester.pump();

      // Verify dark mode is enabled
      expect(themeManager.isDarkMode, true);

      // Switch back to light mode
      themeManager.toggleTheme(false);
      await tester.pump();

      // Verify light mode is enabled
      expect(themeManager.isDarkMode, false);
    });

    testWidgets('Navigation between pages works', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const MyApp());

      // Navigate to home page (simulate splash screen completion)
      await tester.pumpAndSettle();

      // Test navigation to different pages
      // Note: You'll need to add specific navigation tests based on your app's navigation structure
    });

    testWidgets('App theming responds to theme changes', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const MyApp());

      // Verify initial theme (light mode)
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, Brightness.light);

      // Switch to dark mode by accessing ThemeManager through context
      await tester.tap(find.byType(Scaffold)); // Tap somewhere to ensure context
      await tester.pump();

      // We'll test the theme mode through the MaterialApp widget
      final BuildContext context = tester.element(find.byType(MaterialApp));
      final themeManager = Provider.of<ThemeManager>(context, listen: false);
      themeManager.toggleTheme(true);
      await tester.pump();

      // Verify theme switched to dark by checking the theme mode
      final updatedMaterialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(updatedMaterialApp.themeMode, ThemeMode.dark);
    });

    // Add more specific tests for your pages
    testWidgets('Catalogue page loads', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            // Add other required providers for CataloguePage
          ],
          child: const MaterialApp(
            home: CataloguePage(),
          ),
        ),
      );

      expect(find.byType(CataloguePage), findsOneWidget);
    });

    testWidgets('My Likes page loads', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(create: (_) => MyLikesViewModel()),
          ],
          child: const MaterialApp(
            home: MyLikesPage(),
          ),
        ),
      );

      expect(find.byType(MyLikesPage), findsOneWidget);
    });

    testWidgets('Settings page loads', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ],
          child: const MaterialApp(
            home: SettingsPage(),
          ),
        ),
      );

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // Error handling test
    testWidgets('Unknown route shows error page', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Try to navigate to unknown route
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed('/unknown-route');
      await tester.pumpAndSettle();

      // Should show page not found
      expect(find.text('Page not found'), findsOneWidget);
    });
  });

  // Basic widget tests for individual components
  group('Component Tests', () {
    testWidgets('Placeholder widget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceholderWidget(title: 'Test Page'),
          ),
        ),
      );

      expect(find.text('Test Page - Coming Soon'), findsOneWidget);
      expect(find.text('This page is under development and will be available soon.'), findsOneWidget);
    });

    testWidgets('Placeholder widget icons match page types', (WidgetTester tester) async {
      // Test different page types and their icons
      final testCases = <Map<String, dynamic>>[
        {'title': 'Language Settings', 'expectedIcon': Icons.language},
        {'title': 'Notifications', 'expectedIcon': Icons.notifications},
        {'title': 'About App', 'expectedIcon': Icons.info},
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PlaceholderWidget(title: testCase['title'] as String),
            ),
          ),
        );

        expect(find.byIcon(testCase['expectedIcon'] as IconData), findsOneWidget);
      }
    });
  });
}