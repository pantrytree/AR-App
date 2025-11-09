import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideSharingPage extends StatelessWidget {
  const GuideSharingPage({super.key});

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
          'Sharing & Collaboration Guide',
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
              title: 'Introduction',
              content:
              'This guide will help you share your projects and collaborate with others efficiently.',
            ),

            // Section describing how to share projects
            const SizedBox(height: 20),
            _buildSection(
              title: 'Sharing Projects',
              content:
              '• Export Project: Save your project locally or cloud.\n'
                  '• Share Link: Generate a link to share with teammates.\n'
                  '• Permissions: Control who can view or edit.',
            ),

            // Section describing collaboration features and tips
            const SizedBox(height: 20),
            _buildSection(
              title: 'Collaboration Tips',
              content:
              '• Invite team members via email.\n'
                  '• Use comments to give feedback.\n'
                  '• Track changes with version history.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper function to build a styled section with title and paragraph/bulleted content
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
