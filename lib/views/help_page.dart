import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/help_page_viewmodel.dart';
import '../utils/colors.dart';


class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HelpPageViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'How can we help you?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildMainOptions(viewModel),
            const SizedBox(height: 32),
            _buildGettingStartedSection(viewModel),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.textFieldBackground,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMainOptions(HelpPageViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildHelpCard(
            icon: Icons.book,
            label: 'Guides',
            onTap: viewModel.onTapGuides,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHelpCard(
            icon: Icons.help_outline,
            label: 'FAQ',
            onTap: viewModel.onTapFAQ,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.secondaryLightPurple,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDarkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGettingStartedSection(HelpPageViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Getting Started',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 16),
        _buildExpandableItem(
          title: 'General description',
          isExpanded: viewModel.isGeneralDescriptionExpanded,
          onTap: () => viewModel.toggleGeneralDescription(),
        ),
        _buildExpandableItem(
          title: 'Import guides',
          isExpanded: viewModel.isImportGuidesExpanded,
          onTap: () => viewModel.toggleImportGuides(),
        ),
        _buildExpandableItem(
          title: 'Additional services',
          isExpanded: viewModel.isAdditionalServicesExpanded,
          onTap: () => viewModel.toggleAdditionalServices(),
        ),
      ],
    );
  }

  Widget _buildExpandableItem({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white, // Updated
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            trailing: RotationTransition(
              turns: AlwaysStoppedAnimation(isExpanded ? 0.5 : 0.0),
              child: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                _getContentForTitle(title),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getContentForTitle(String title) {
    switch (title) {
      case 'General description':
        return 'This section provides an overview of our app features and how to get started with basic functionality.';
      case 'Import guides':
        return 'Learn how to import your existing data and guides into our platform for seamless integration.';
      case 'Additional services':
        return 'Discover premium features and additional services that can enhance your experience.';
      default:
        return 'Content coming soon...';
    }
  }


  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 4,
      backgroundColor: AppColors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: AppColors.black),
          label: '',
        ),
      ],
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.black,
    );
  }
}