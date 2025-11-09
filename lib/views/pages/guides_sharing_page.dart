// GUIDE SHARING PAGE
// This page provides users with written guidance on how to share
// their Roomantics projects and collaborate effectively with others.
//
// It uses simple text sections for clarity and readability,

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
// Stateless Widget: GuideSharingPage
// Displays static instructional content about project sharing
// and team collaboration features. It follows a scrollable
// column layout with section headers and body text.
class GuideSharingPage extends StatelessWidget {
  const GuideSharingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,

      // Top AppBar containing the title and back button
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
          // Navigates back to the previous page when pressed
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

      // The page content is wrapped in a scroll view to prevent overflow
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction section
            _buildSection(
              title: 'Introduction',
              content:
                  'This guide will help you share your projects and collaborate with others efficiently.',
            ),
            const SizedBox(height: 20),

            // Section describing how to share projects
            _buildSection(
              title: 'Sharing Projects',
              content:
                  '• Export Project: Save your project locally or to the cloud.\n'
                  '• Share Link: Generate a link to share with teammates.\n'
                  '• Permissions: Control who can view or edit your project.',
            ),
            const SizedBox(height: 20),

            // Section describing collaboration best practices
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
  // Helper Method: _buildSection
  // Builds a reusable text section consisting of:
  // - A title (bold and slightly larger)
  // - A content paragraph (smaller body text)
  //
  // Parameters:
  // - title: The heading text for the section
  // - content: The descriptive text or bullet list that follows
  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 8),

        // Section body text
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.primaryDarkBlue.withOpacity(0.9),
            height: 1.5, // Adjusted for better readability
          ),
        ),
      ],
    );
  }
}
