import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            color: AppColors.primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.secondaryBackground,
        foregroundColor: AppColors.primaryDarkBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryDarkBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
          onPressed: () {
            // Navigate back to home page instead of previous page
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ),
      body: const Center(
        child: Text('Login Page - iyeza soon soon'),
      ),
    );
  }
}