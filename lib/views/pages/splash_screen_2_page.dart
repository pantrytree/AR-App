import 'package:flutter/material.dart';
import '/utils/colors.dart';

class SplashScreen2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color using the app's color system
      backgroundColor: AppColors.splashBrackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            // App icon/logo - using a chair icon to represent room/design theme
            Icon(Icons.chair, size: 160, color: Colors.deepPurple[900]),
            SizedBox(height: 20), // Spacing between icon and text
            
            // App name/title
            Text(
              'ROOMANTICS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.appNamecolor, // Use app-specific color for brand consistency
                letterSpacing: 2, // Increased spacing for better visual appeal
              ),
            ),
          ],
        ),
      ),
    );
  }
}
