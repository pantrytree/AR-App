import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/utils/colors.dart';
import '/services/design_service.dart';
import '/models/design.dart';
import '/models/design_object.dart';

class RoomieLabGallery extends StatefulWidget {
  const RoomieLabGallery({super.key});

  @override
  State<RoomieLabGallery> createState() => _RoomieLabGalleryState();
}

class _RoomieLabGalleryState extends State<RoomieLabGallery> {
  // Firebase services for data management
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DesignService _designService = DesignService();

  // State variables for designs and UI
  List<Design> _designs = [];
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Office',
    'Dining Room',
    'Bathroom',
    'Uncategorized',
  ];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  // Load designs from Firebase via DesignService
  Future<void> _loadDesigns() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final designs = await _designService.getDesigns();

      setState(() {
        _designs = designs;
        _isLoading = false;
      });

      print('Loaded ${designs.length} designs from Firebase');
    } catch (e) {
      print('Error loading designs: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Filter designs based on selected category
  List<Design> get _filteredDesigns {
    if (_selectedCategory == 'All') {
      return _designs;
    }
    return _designs.where((design) =>
    _getDesignCategory(design) == _selectedCategory).toList();
  }

  // Determine design category based on name keywords
  String _getDesignCategory(Design design) {
    final name = design.name.toLowerCase();

    if (name.contains('living') || name.contains('sofa') || name.contains('tv'))
      return 'Living Room';
    if (name.contains('bed') || name.contains('bedroom') || name.contains('mattress'))
      return 'Bedroom';
    if (name.contains('kitchen') || name.contains('cabinets') || name.contains('counter'))
      return 'Kitchen';
    if (name.contains('office') || name.contains('desk') || name.contains('workspace'))
      return 'Office';
    if (name.contains('dining') || name.contains('table') || name.contains('chair'))
      return 'Dining Room';
    if (name.contains('bath') || name.contains('toilet') || name.contains('shower'))
      return 'Bathroom';

    return 'Uncategorized';
  }

  // Check if design has a valid image URL
  bool _hasImage(Design design) {
    return design.imageUrl != null &&
        design.imageUrl!.isNotEmpty &&
        design.imageUrl!.startsWith('http');
  }

  // Delete design from Firebase
  Future<void> _deleteDesign(Design design) async {
    try {
      await _designService.deleteDesign(design.id);
      await _loadDesigns(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Design deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting design: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting design: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Designs Gallery'),
        backgroundColor: AppColors.primaryLightPurple,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button to reload designs
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDesigns,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
          ? _buildErrorState()
          : Column(
        children: [
          // Category Filter section
          _buildCategoryFilter(),

          // Designs Grid section
          Expanded(
            child: _filteredDesigns.isEmpty
                ? _buildEmptyState()
                : _buildDesignsGrid(),
          ),
        ],
      ),
    );
  }

  // Horizontal category filter chips
  Widget _buildCategoryFilter() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Category:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: AppColors.getCardBackground(context),
                    selectedColor: AppColors.primaryLightPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.getTextColor(context),
                    ),
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Grid view of design cards
  Widget _buildDesignsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _filteredDesigns.length,
        itemBuilder: (context, index) {
          return _buildDesignCard(_filteredDesigns[index]);
        },
      ),
    );
  }

  // Individual design card widget
  Widget _buildDesignCard(Design design) {
    final hasImage = _hasImage(design);
    final category = _getDesignCategory(design);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDesignDetails(design),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Design Image/Thumbnail section
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightPurple.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: hasImage
                        ? DecorationImage(
                      image: NetworkImage(design.imageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: !hasImage
                      ? Center(
                    child: Icon(
                      Icons.photo_library,
                      size: 50,
                      color: AppColors.primaryLightPurple.withOpacity(0.5),
                    ),
                  )
                      : null,
                ),

                // Design Info section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.name,
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
                        '${design.objects.length} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryLightPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(design.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Delete button overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                  onPressed: () => _confirmDeleteDesign(design),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loading state with progress indicator
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryLightPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your designs...',
            style: TextStyle(
              color: AppColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Error state for failed data loading
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load designs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadDesigns,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Empty state when no designs are found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppColors.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 20),
          Text(
            'No designs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory == 'All'
                ? 'Create your first design to get started!'
                : 'No designs in the $_selectedCategory category',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Design'),
          ),
          // Show "View All" button when filtered category is empty
          if (_selectedCategory != 'All')
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                });
              },
              child: Text(
                'View All Designs',
                style: TextStyle(
                  color: AppColors.primaryLightPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Show design details in a dialog
  void _showDesignDetails(Design design) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(design.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDesignImage(design, height: 200),
              const SizedBox(height: 16),
              _buildDesignInfo(design),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewDesignFullScreen(design);
            },
            child: const Text('View Full Screen'),
          ),
        ],
      ),
    );
  }

  // Design image widget with fallback
  Widget _buildDesignImage(Design design, {double height = 120}) {
    final hasImage = _hasImage(design);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLightPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        image: hasImage
            ? DecorationImage(
          image: NetworkImage(design.imageUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: !hasImage
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              size: height * 0.3,
              color: AppColors.primaryLightPurple.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  // Design information section
  Widget _buildDesignInfo(Design design) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Category:', _getDesignCategory(design)),
        _buildInfoRow('Project ID:', design.projectId),
        _buildInfoRow('Date Created:', _formatDate(design.createdAt)),
        _buildInfoRow('Last Updated:', _formatDate(design.updatedAt)),
        _buildInfoRow('Objects:', '${design.objects.length} items'),

        // Show object list if design has objects
        if (design.objects.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Objects in this design:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          ...design.objects.take(5).map((obj) =>
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text('• Item ID: ${obj.itemId}'),
              )
          ).toList(),
          if (design.objects.length > 5)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text('... and ${design.objects.length - 5} more'),
            ),
        ],
      ],
    );
  }

  // Helper widget for info row layout
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Full screen image viewer dialog
  void _viewDesignFullScreen(Design design) {
    final hasImage = _hasImage(design);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            image: hasImage
                ? DecorationImage(
              image: NetworkImage(design.imageUrl!),
              fit: BoxFit.contain,
            )
                : null,
          ),
          child: Stack(
            children: [
              // Close button overlay
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Design info overlay at bottom
              if (hasImage)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          design.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${design.objects.length} items • ${_getDesignCategory(design)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Created: ${_formatDate(design.createdAt)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Fallback content when no image available
              if (!hasImage)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 80,
                        color: AppColors.primaryLightPurple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No image available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirmation dialog for design deletion
  void _confirmDeleteDesign(Design design) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Design?'),
        content: Text('Are you sure you want to delete "${design.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteDesign(design);
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
