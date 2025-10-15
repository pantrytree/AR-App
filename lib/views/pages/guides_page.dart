import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Guides',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 32.0), // Top padding below AppBar
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Browse Guides title
                    Text(
                      'Browse Guides',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Guide cards list
                    _buildGuideCard(
                      context,
                      icon: Icons.book,
                      title: 'Getting Started Guide',
                      description: 'Learn to set up your account and navigate the app.',
                    ),
                    const SizedBox(height: 16),

                    _buildGuideCard(
                      context,
                      icon: Icons.edit,
                      title: 'Design Tools Guide',
                      description: 'Master the app\'s features to create custom projects.',
                    ),
                    const SizedBox(height: 16),

                    _buildGuideCard(
                      context,
                      icon: Icons.share,
                      title: 'Sharing & Collaboration Guide',
                      description: 'Share projects and work with others.',
                    ),
                    const SizedBox(height: 16),

                    _buildGuideCard(
                      context,
                      icon: Icons.file_upload,
                      title: 'Importing Media Guide',
                      description: 'Learn how to import and manage your media files.',
                    ),
                    const SizedBox(height: 16), // Bottom spacing after last card
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable guide card widget
  Widget _buildGuideCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.secondaryLightPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.secondaryLightPurple,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        subtitle: Text(  // Removed explicit Padding—ListTile handles ~8px top spacing natively for better consistency
          description,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.grey,
          ),
        ),
        trailing: const Icon(  // Added subtle trailing arrow for tap affordance (matches Material icons, no visual bloat)
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.grey,
        ),
        onTap: () {
          // Add navigation to specific guide content here
        },
      ),
    );
  }
}