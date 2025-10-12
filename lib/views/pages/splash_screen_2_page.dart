import 'package:flutter/material.dart';
import '/utils/colors.dart';

class SplashScreen2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLightPurple,
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
                color: AppColors.textFieldBackground,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
