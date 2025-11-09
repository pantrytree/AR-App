import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideImportingMediaPage extends StatelessWidget {
  const GuideImportingMediaPage({super.key});

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
          'Importing Media Guide',
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
            // Overview section
            _buildSection(
              title: 'Overview',
              content:
              'Learn how to import images, videos, and 3D models into your AR projects.',
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // Images & Videos section
            _buildSection(
              title: 'Importing Images & Videos',
              content:
              '• Tap the "Import" button.\n'  // Step 1
                  '• Choose media from your gallery or cloud storage.\n'  // Step 2
                  '• Adjust the file as needed in the project workspace.',  // Step 3
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // 3D Models section
            _buildSection(
              title: 'Importing 3D Models',
              content:
              '• Supported formats: .obj, .fbx, .glb.\n'  // Supported file formats
                  '• Use the preview before importing.\n'  // Preview feature
                  '• Place the model in your scene using the design tools.',  // Placement instructions
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
