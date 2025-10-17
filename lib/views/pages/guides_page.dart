import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/colors.dart';
import '../../viewmodels/guides_page_viewmodel.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuidesPageViewModel(),
      child: Consumer<GuidesPageViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Guides',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              centerTitle: true,
            ),
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(vm),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildGuideGrid(vm),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(GuidesPageViewModel vm) {
    return TextField(
      onChanged: vm.setSearchQuery,
      style: GoogleFonts.inter(color: AppColors.primaryDarkBlue),
      decoration: InputDecoration(
        hintText: 'Search guides...',
        hintStyle: GoogleFonts.inter(color: AppColors.grey),
        prefixIcon: Icon(Icons.search, color: AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: AppColors.white.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildGuideGrid(GuidesPageViewModel vm) {
    if (vm.guides.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No guides found',
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: AnimationLimiter(
        child: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final guide = vm.guides[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () {
                        final page = vm.getPageForGuide(guide.title);
                        if (page != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                        }
                      },
                      child: _buildGuideCard(
                        context,
                        icon: vm.parseIcon(guide.iconString),
                        title: guide.title,
                        description: guide.description,
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: vm.guides.length,
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkBlue.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLightPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.secondaryLightPurple, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryDarkBlue, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey, height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}