import 'package:flutter/material.dart';
import '/utils/colors.dart';

class SplashScreenPage extends StatelessWidget {
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
            SizedBox(height: 20), // Spacing between icon and app name
            
            // App name/title display
            Text(
              'ROOMANTICS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.appNamecolor, // Use app-specific color for brand consistency
                letterSpacing: 2, // Increased spacing for better visual appeal
              ),
            ),
            SizedBox(height: 60), // Larger spacing before the action buttons
            
            // Sign Up button - navigates to signup page
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup'); // Navigate to signup route
              },
              child: Text('Sign Up'), // Button label
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.signupButtonBackground, // Button background color
                foregroundColor: AppColors.signupButtonText, // Text color
                minimumSize: Size(220, 50), // Consistent button size
              ),
            ),
            SizedBox(height: 16), // Spacing between buttons
            
            // Login button - navigates to login page
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Navigate to login route
              },
              child: Text('Login'), // Button label
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.loginButtonBackground, // Button background color
                foregroundColor: AppColors.loginButtonText, // Text color
                minimumSize: Size(220, 50), // Consistent button size matching signup button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
