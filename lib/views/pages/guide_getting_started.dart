import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideGettingStartedPage extends StatelessWidget {
  const GuideGettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Getting Started Guide',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Welcome!',
              content:
              'Welcome to the AR app! This guide will help you set up your account and navigate through the features efficiently.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Creating Your Account',
              content:
              '1. Tap on "Sign Up" on the home screen.\n'
                  '2. Enter your details: name, email, and password.\n'
                  '3. Verify your email through the confirmation link.\n'
                  '4. Log in using your credentials.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Navigating the App',
              content:
              '• Home Screen: Browse featured content.\n'
                  '• AR Projects: Start creating AR experiences.\n'
                  '• Account Hub: Manage your profile, settings, and guides.\n'
                  '• Help & FAQ: Access tutorials and support.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Tips & Tricks',
              content:
              '• Keep your app updated for the best performance.\n'
                  '• Enable camera and storage permissions to fully utilize AR features.\n'
                  '• Explore the guides for advanced tips.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.primaryDarkBlue.withOpacity(0.9),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
