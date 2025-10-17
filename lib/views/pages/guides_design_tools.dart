import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuideDesignToolsPage extends StatelessWidget {
  const GuideDesignToolsPage({super.key});

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
          'Design Tools Guide',
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
              'Learn how to master the app’s design tools to create stunning AR projects.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Tool Overview',
              content:
              '• Object Placement: Add 3D objects to your scene.\n'
                  '• Scaling & Rotation: Adjust objects to fit your design.\n'
                  '• Materials & Textures: Customize colors and surfaces.\n'
                  '• Layers: Organize elements for complex scenes.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Pro Tips',
              content:
              '• Use the grid view to align objects precisely.\n'
                  '• Group objects to move them together.\n'
                  '• Preview in AR mode frequently to check scale.',
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