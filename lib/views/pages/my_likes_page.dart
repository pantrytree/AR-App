import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../services/likes_service.dart';
import '../../../utils/colors.dart';
import '../../theme/theme.dart';
import '../../../utils/text_components.dart';
import '/views/pages/furniture_catalogue_page.dart';

class MyLikesPage extends StatefulWidget {
  const MyLikesPage({super.key});

  @override
  State<MyLikesPage> createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
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
              'My Likes',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.getAppBarForeground(context),
              ),
            ),
            centerTitle: true,
          ),
          body: Consumer<LikesService>(
            builder: (context, likesService, child) {
              final likedItems = _selectedCategory == 'All'
                  ? likesService.likedItems
                  : likesService.getLikedItemsByCategory(_selectedCategory);

              return Column(
                children: [
                  _buildCategoryTabs(),
                  Expanded(
                    child: likedItems.isEmpty
                        ? _buildEmptyState(context)
                        : Column(
                      children: [
                        Expanded(child: _buildFurnitureGrid(context, likedItems, likesService)),
                        _buildExploreMoreButton(context),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    final List<String> categories = ['All', 'Living Room', 'Bedroom', 'Office', 'Dining', 'Kitchen'];

    return Container(
      color: AppColors.getBackgroundColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildCategoryTab(category, isSelected),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 70),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.getCategoryTabSelected(context)
              : AppColors.getCategoryTabUnselected(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.getCategoryTabSelected(context)
                : AppColors.getCategoryTabUnselected(context),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.getTextColor(context),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.likesHeart
          ),
          const SizedBox(height: 16),
          Text(
            'No liked items yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you like will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          _buildPulsingExploreButton(context, 'Explore Furniture'),
        ],
      ),
    );
  }

  Widget _buildFurnitureGrid(BuildContext context, List<dynamic> likedItems, LikesService likesService) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: likedItems.length,
      itemBuilder: (context, index) => _buildFurnitureCard(context, likedItems[index], likesService),
    );
  }

  Widget _buildFurnitureCard(BuildContext context, dynamic item, LikesService likesService) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
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
                child: Center(
                  child: Icon(
                    _getFurnitureIcon(item.furnitureType),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.roomCategory} • ${item.furnitureType}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.primaryPurple),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ],
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
              onTap: () => likesService.removeFromLikes(item.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
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
                    size: 20
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _buildPulsingExploreButton(context, 'Explore More Furniture'),
    );
  }

  Widget _buildPulsingExploreButton(BuildContext context, String text) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FurnitureCataloguePage()),
          );
        },
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  IconData _getFurnitureIcon(String furnitureType) {
    switch (furnitureType.toLowerCase()) {
      case 'bed':
        return Icons.bed;
      case 'sofa':
        return Icons.weekend;
      case 'chair':
        return Icons.chair;
      case 'table':
        return Icons.table_restaurant;
      case 'lamp':
        return Icons.lightbulb;
      case 'wardrobe':
        return Icons.king_bed;
      default:
        return Icons.chair;
    }
  }
}