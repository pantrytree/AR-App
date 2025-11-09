import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/help_page_viewmodel.dart';
import '../../../utils/colors.dart';
import '../../views/widgets/bottom_nav_bar.dart';
import '../../views/pages/faq_page.dart';
import '../../views/pages/guides_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpPageViewModel()..loadHelpData(),
      child: Consumer<HelpPageViewModel>(
        builder: (context, viewModel, child) {
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
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(viewModel),
                            const SizedBox(height: 24),
                            _buildMainOptions(viewModel, context),
                            const SizedBox(height: 32),
                            _buildDynamicSections(viewModel),
                          ],
                        ),
                      ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: 4,
              onTap: (index) => _handleBottomNavTap(context, index),
            ),
          );
        },
      ),
    );
  }

  // Handles navigation between main app sections.
  void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/my-likes', (route) => false);
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(context, '/camera-page', (route) => false);
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(context, '/catalogue', (route) => false);
        break;
      case 4:
        Navigator.pushNamedAndRemoveUntil(context, '/account-hub', (route) => false);
        break;
    }
  }

  // Search bar with focus-based animation.
  Widget _buildSearchBar(HelpPageViewModel viewModel) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFocused = false;
        final focusNode = FocusNode();

        focusNode.addListener(() {
          setState(() => isFocused = focusNode.hasFocus);
        });

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? AppColors.primaryPurple.withOpacity(0.25)
                    : AppColors.primaryPurple.withOpacity(0.15),
                blurRadius: isFocused ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            focusNode: focusNode,
            onChanged: viewModel.setSearchQuery,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.primaryDarkBlue,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: isFocused ? AppColors.primaryPurple : AppColors.grey,
                size: 22,
              ),
              hintText: 'Search for help topics...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.grey.withOpacity(0.8),
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
        );
      },
    );
  }

  // Displays cards for Guides and FAQ pages.
  Widget _buildMainOptions(HelpPageViewModel viewModel, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildHelpCard(
            icon: Icons.book,
            label: 'Guides',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuidesPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHelpCard(
            icon: Icons.help_outline,
            label: 'FAQ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  // Small reusable card widget.
  Widget _buildHelpCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondaryLightPurple, size: 48),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
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

  // Builds a list of expandable help topics.
  Widget _buildDynamicSections(HelpPageViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help Topics',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 16),
        ...viewModel.filteredHelpItems.map((item) {
          bool isExpanded = viewModel.getExpansionState(item['id']);
          return _buildExpandableItem(
            title: item['title'],
            isExpanded: isExpanded,
            onTap: () => viewModel.toggleExpansion(item['id']),
            content: item['content'] ?? "",
          );
        }).toList(),
      ],
    );
  }

  // Single expandable card for a help topic.
  Widget _buildExpandableItem({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required String content,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.grey,
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
