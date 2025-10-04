import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/my_likes_page_viewmodel.dart';
import '../../utils/colors.dart';

class MyLikesPage extends StatelessWidget {
  const MyLikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyLikesViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadLikedItems();
    });

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
          'My Likes',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MyLikesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${viewModel.errorMessage}'));
          }

          return Column(
            children: [
              _buildCategoryTabs(viewModel),

              Expanded(
                child: viewModel.getFilteredItems().isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(viewModel),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }


  Widget _buildCategoryTabs(MyLikesViewModel viewModel) {
    return Container(
      color: AppColors.secondaryBackground,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: viewModel.categories.map((category) {
          final isSelected = category == viewModel.selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildCategoryTab(category, isSelected, viewModel),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTab(String category, bool isSelected, MyLikesViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.setSelectedCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.likesTabSelected
              : AppColors.likesTabUnselected,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.likesTabSelected
                : AppColors.likesTabUnselected,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.primaryDarkBlue,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // 📭 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppColors.likesHeart,
          ),
          const SizedBox(height: 16),
          Text(
            'No liked items yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you like will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(MyLikesViewModel viewModel) {
    final filteredItems = viewModel.getFilteredItems();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) => _buildProductCard(filteredItems[index], viewModel),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, MyLikesViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.chair, size: 40, color: AppColors.primaryPurple),
                ),
              ),

              // 📝 Product Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['dimensions'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => viewModel.removeLikedItem(item['id']),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white, // ✅
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.likesHeart,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      backgroundColor: AppColors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: AppColors.black),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite, color: AppColors.likesHeart),
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
      selectedItemColor: AppColors.likesHeart,
      unselectedItemColor: AppColors.black,
    );
  }
}