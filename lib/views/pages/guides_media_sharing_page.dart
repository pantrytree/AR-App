import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideImportingMediaPage extends StatelessWidget {
  const GuideImportingMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Root scaffold for page layout
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
          'Importing Media Guide',
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
              title: 'Overview',
              content:
              'Learn how to import images, videos, and 3D models into your AR projects.',
            ),

            // Section: Importing Images & Videos
            const SizedBox(height: 20),
            _buildSection(
              title: 'Importing Images & Videos',
              content:
              '• Tap the "Import" button.\n'
                  '• Choose media from your gallery or cloud storage.\n'
                  '• Adjust the file as needed in the project workspace.',
            ),

            // Section: Importing 3D Models
            const SizedBox(height: 20),
            _buildSection(
              title: 'Importing 3D Models',
              content:
              '• Supported formats: .obj, .fbx, .glb.\n'
                  '• Use the preview before importing.\n'
                  '• Place the model in your scene using the design tools.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper: Build a styled guide section with header and body content
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
