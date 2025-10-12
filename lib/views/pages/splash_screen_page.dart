import 'package:flutter/material.dart';
import '/utils/colors.dart';

class SplashScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chair, size: 160, color: Colors.deepPurple[900]),
            SizedBox(height: 20),
            Text(
              'ROOMANTICS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkBlue,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
                foregroundColor: AppColors.textFieldBackground,
                minimumSize: Size(220, 50),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textFieldBackground,
                foregroundColor: AppColors.buttonPrimary,
                minimumSize: Size(220, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
