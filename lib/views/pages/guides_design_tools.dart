import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideDesignToolsPage extends StatelessWidget {
  const GuideDesignToolsPage({super.key});

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
          'Design Tools Guide',
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
            // Introduction section
            _buildSection(
              title: 'Introduction',
              content:
              'Learn how to master the app\'s design tools to create stunning AR projects.',
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // Tool Overview section
            _buildSection(
              title: 'Tool Overview',
              content:
              '• Object Placement: Add 3D objects to your scene.\n'  // Object placement tool
                  '• Scaling & Rotation: Adjust objects to fit your design.\n'  // Transformation tools
                  '• Materials & Textures: Customize colors and surfaces.\n'  // Material customization
                  '• Layers: Organize elements for complex scenes.',  // Layer management
            ),
            const SizedBox(height: 20), // Spacing between sections
            
            // Pro Tips section
            _buildSection(
              title: 'Pro Tips',
              content:
              '• Use the grid view to align objects precisely.\n'  // Grid alignment tip
                  '• Group objects to move them together.\n'  // Object grouping tip
                  '• Preview in AR mode frequently to check scale.',  // AR preview tip
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
