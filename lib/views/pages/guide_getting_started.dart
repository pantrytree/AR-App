import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideGettingStartedPage extends StatelessWidget {
  const GuideGettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color using app's color system
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 1, // Subtle shadow for app bar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
          onPressed: () => Navigator.pop(context), // Navigate back to previous screen
        ),
        title: Text(
          'Getting Started Guide',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        centerTitle: true, // Center the title text
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildSection(
              title: 'Welcome!',
              content:
              'Welcome to the AR app! This guide will help you set up your account and navigate through the features efficiently.',
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // Account creation section with numbered steps
            _buildSection(
              title: 'Creating Your Account',
              content:
              '1. Tap on "Sign Up" on the home screen.\n'  // Step 1
                  '2. Enter your details: name, email, and password.\n'  // Step 2
                  '3. Verify your email through the confirmation link.\n'  // Step 3
                  '4. Log in using your credentials.',  // Step 4
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // App navigation section
            _buildSection(
              title: 'Navigating the App',
              content:
              '• Home Screen: Browse featured content.\n'  // Home screen description
                  '• AR Projects: Start creating AR experiences.\n'  // Projects section
                  '• Account Hub: Manage your profile, settings, and guides.\n'  // Account management
                  '• Help & FAQ: Access tutorials and support.',  // Help resources
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // Tips and tricks section
            _buildSection(
              title: 'Tips & Tricks',
              content:
              '• Keep your app updated for the best performance.\n'  // Update recommendation
                  '• Enable camera and storage permissions to fully utilize AR features.\n'  // Permission advice
                  '• Explore the guides for advanced tips.',  // Additional resources
            ),
            const SizedBox(height: 30), // Extra spacing at the bottom
          ],
        ),
      ),
    );
  }

  // Reusable widget for creating consistent section layouts
  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700, // Bold for section titles
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 8), // Spacing between title and content
        // Section content
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.primaryDarkBlue.withOpacity(0.9), // Slightly transparent for content
            height: 1.5, // Line height for better readability
          ),
        ),
      ],
    );
  }
}
