import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../utils/colors.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> guides = const [
    {
      'icon': 'Icons.book',
      'title': 'Getting Started Guide',
      'description': 'Learn to set up your account and navigate the app.',
    },
    {
      'icon': 'Icons.edit',
      'title': 'Design Tools Guide',
      'description': 'Master the app\'s features to create custom projects.',
    },
    {
      'icon': 'Icons.share',
      'title': 'Sharing & Collaboration Guide',
      'description': 'Share projects and work with others.',
    },
    {
      'icon': 'Icons.file_upload',
      'title': 'Importing Media Guide',
      'description': 'Learn how to import and manage your media files.',
    },
  ];

  List<Map<String, String>> _filteredGuides = [];
  late AnimationController _animationController;

  // Keep track of favorites locally
  final Set<int> _favorites = {};

  @override
  void initState() {
    super.initState();
    _filteredGuides = List.from(guides);
    _searchController.addListener(_filterGuides);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterGuides() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGuides = query.isEmpty
          ? List.from(guides)
          : guides.where((guide) {
        return guide['title']!.toLowerCase().contains(query) ||
            guide['description']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  IconData _parseIcon(String iconString) {
    switch (iconString) {
      case 'Icons.book':
        return Icons.book;
      case 'Icons.edit':
        return Icons.edit;
      case 'Icons.share':
        return Icons.share;
      case 'Icons.file_upload':
        return Icons.file_upload;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Browse Guides',
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDarkBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: AppColors.primaryDarkBlue),
                      decoration: InputDecoration(
                        hintText: 'Search guides...',
                        hintStyle: GoogleFonts.inter(color: AppColors.grey),
                        prefixIcon: Icon(Icons.search, color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_filteredGuides.isEmpty && _searchController.text.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No guides found',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
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
                      final guide = _filteredGuides[index];
                      final isFavorite = _favorites.contains(index);
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: SlideAnimation(
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                // Simple scale animation on tap
                                // You can add navigation here later
                              },
                              child: Stack(
                                children: [
                                  _buildGuideCard(
                                    context,
                                    icon: _parseIcon(guide['icon']!),
                                    title: guide['title']!,
                                    description: guide['description']!,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isFavorite) {
                                            _favorites.remove(index);
                                          } else {
                                            _favorites.add(index);
                                          }
                                        });
                                      },
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.redAccent
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _filteredGuides.length,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
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
                child: Icon(
                  icon,
                  color: AppColors.secondaryLightPurple,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDarkBlue,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.grey,
                  height: 1.3,
                ),
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
