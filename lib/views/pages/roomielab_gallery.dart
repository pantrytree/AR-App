import 'dart:io';
import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/services/roomielab_service.dart';
import '/models/roomielab_model.dart';

class RoomieLabGallery extends StatefulWidget {
  const RoomieLabGallery({super.key});

  @override
  State<RoomieLabGallery> createState() => _RoomieLabGalleryState();
}

class _RoomieLabGalleryState extends State<RoomieLabGallery> {
  List<RoomieLabDesign> _allDesigns = [];
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Sofas',
    'Chairs',
    'Tables',
    'Beds',
    'Lighting',
    'Decor',
    'Uncategorized',
  ];
  final RoomieLabService _roomieLabService = RoomieLabService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllDesigns();
  }

  Future<void> _loadAllDesigns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final designs = await _roomieLabService.getDesigns();
      setState(() {
        _allDesigns = designs;
        _isLoading = false;
      });
      print('Loaded ${designs.length} designs from storage');
    } catch (e) {
      print('Error loading designs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<RoomieLabDesign> get _filteredDesigns {
    if (_selectedCategory == 'All') {
      return _allDesigns;
    }
    return _allDesigns.where((design) => design.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Designs Gallery'),
        backgroundColor: AppColors.primaryLightPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAllDesigns,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 16, bottom: 16),
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
                  ),
                );
              },
            ),
          ),

          // Designs Grid
          Expanded(
            child: _filteredDesigns.isEmpty
                ? _buildEmptyState()
                : Padding(
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
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildDesignCard(RoomieLabDesign design) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => _showDesignDetails(design),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Design Image/Thumbnail
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  image: design.imagePath.isNotEmpty
                      ? DecorationImage(
                    image: FileImage(File(design.imagePath)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: design.imagePath.isEmpty
                    ? Center(
                  child: Icon(
                    Icons.photo,
                    size: 50,
                    color: AppColors.primaryLightPurple,
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 12),

              // Design Info
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
                '${design.placedFurniture.length} items • ${design.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${design.createdAt.day}/${design.createdAt.month}/${design.createdAt.year}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                ? 'Capture your first AR design to get started!'
                : 'No designs in the ${_selectedCategory} category',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to camera
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: Text('Create Design'),
          ),
          if (_selectedCategory != 'All')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                });
              },
              child: Text('View All Designs'),
            ),
        ],
      ),
    );
  }

  void _showDesignDetails(RoomieLabDesign design) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(design.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${design.category}'),
              Text('Date Created: ${design.createdAt.toString().split(' ')[0]}'),
              Text('Furniture Items: ${design.placedFurniture.length}'),
              const SizedBox(height: 16),

              // Display the actual saved image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  image: design.imagePath.isNotEmpty
                      ? DecorationImage(
                    image: FileImage(File(design.imagePath)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: design.imagePath.isEmpty
                    ? Center(
                  child: Icon(
                    Icons.photo,
                    size: 60,
                    color: AppColors.primaryLightPurple,
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 16),
              if (design.placedFurniture.isNotEmpty) ...[
                Text(
                  'Furniture in this design:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                ...design.placedFurniture.take(3).map((furniture) =>
                    Text('• ${furniture.furnitureName} (${furniture.furnitureType})')
                ),
                if (design.placedFurniture.length > 3)
                  Text('... and ${design.placedFurniture.length - 3} more'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewDesign(design);
            },
            child: Text('View Design'),
          ),
          IconButton(
            onPressed: () {
              _deleteDesign(design);
            },
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _viewDesign(RoomieLabDesign design) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: design.imagePath.isNotEmpty
              ? BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(design.imagePath)),
              fit: BoxFit.contain,
            ),
          )
              : BoxDecoration(
            color: AppColors.primaryLightPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Fallback if no image
              if (design.imagePath.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo,
                        size: 80,
                        color: AppColors.primaryLightPurple,
                      ),
                      const SizedBox(height: 16),
                      Text(
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

  void _deleteDesign(RoomieLabDesign design) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Design?'),
        content: Text('Are you sure you want to delete "${design.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              try {
                await _roomieLabService.deleteDesign(design.id);
                await _loadAllDesigns(); // Refresh the list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Design deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting design: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}