import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Roomantics/main.dart';
import 'package:Roomantics/views/pages/splash_screen_page.dart';

void main() {
  testWidgets('RoomanticApp loads initial SplashScreenPage', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(RoomanticApp());

    // Trigger a frame
    await tester.pumpAndSettle();

    // Verify that SplashScreenPage is displayed
    expect(find.byType(SplashScreenPage), findsOneWidget);

    // Optionally, check if your app title text exists (if your splash has it)
    // expect(find.text('Roomantics'), findsOneWidget);
  });
}
