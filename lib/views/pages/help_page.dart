import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/help_page_viewmodel.dart';
import '../../../utils/colors.dart';
import '../../theme/theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Initialize ViewModel and load JSON data
      create: (_) => HelpPageViewModel()..loadHelpData(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<HelpPageViewModel>(
            builder: (context, viewModel, child) {
              return Scaffold(
                backgroundColor: AppColors.getBackgroundColor(context),
                appBar: AppBar(
                  backgroundColor: AppColors.getAppBarBackground(context),
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.getAppBarForeground(context)
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'How can we help you?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getAppBarForeground(context),
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
                    style: TextStyle(color: AppColors.error),
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context, viewModel),
                      const SizedBox(height: 24),
                      _buildMainOptions(context, viewModel),
                      const SizedBox(height: 32),
                      _buildDynamicSections(context, viewModel),
                    ],
                  ),
                ),
                // Bottom navigation bar removed
              );
            },
          );
        },
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar(BuildContext context, HelpPageViewModel viewModel) {
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
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isFocused
                    ? AppColors.getPrimaryColor(context).withOpacity(0.25)
                    : AppColors.getPrimaryColor(context).withOpacity(0.15),
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
              color: AppColors.getTextColor(context),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: isFocused ? AppColors.getPrimaryColor(context) : AppColors.getSecondaryTextColor(context),
                size: 22,
              ),
              hintText: 'Search for help topics...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context).withOpacity(0.8),
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.getCardBackground(context),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
        );
      },
    );
  }

  // Guides & FAQ cards(buttons-will add navigation soon)
  Widget _buildMainOptions(BuildContext context, HelpPageViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildHelpCard(
            context,
            icon: Icons.book,
            label: 'Guides',
            onTap: viewModel.onTapGuides,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildHelpCard(
            context,
            icon: Icons.help_outline,
            label: 'FAQ',
            onTap: viewModel.onTapFAQ,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpCard(
      BuildContext context, {
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
          color: AppColors.getCardBackground(context),
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
            Icon(
                icon,
                color: AppColors.secondaryLightPurple, // Keep brand color
                size: 48
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  list of topics
  Widget _buildDynamicSections(BuildContext context, HelpPageViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help Topics',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        ...viewModel.filteredHelpItems.map((item) {
          bool isExpanded = viewModel.getExpansionState(item['id']);
          return _buildExpandableItem(
            context,
            title: item['title'],
            isExpanded: isExpanded,
            onTap: () => viewModel.toggleExpansion(item['id']),
            content: item['content'] ?? "",
          );
        }).toList(),
      ],
    );
  }

  // --- Individual expandable item ---
  Widget _buildExpandableItem(
      BuildContext context, {
        required String title,
        required bool isExpanded,
        required VoidCallback onTap,
        required String content,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
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
                color: AppColors.getTextColor(context),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.getSecondaryTextColor(context),
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
                  color: AppColors.getSecondaryTextColor(context),
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}