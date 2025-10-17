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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  @override
  void initState() {
    super.initState();
    _loadDesignsFromFirebase();
  }

  Future<void> _loadDesignsFromFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final querySnapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final designs = querySnapshot.docs.map((doc) {
        return Design.fromFirestore(doc);
      }).toList();

      setState(() {
        _designs = designs;
        _isLoading = false;
      });

      print('Loaded ${designs.length} designs from Firebase');
    } catch (e) {
      print('Error loading designs from Firebase: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Design> get _filteredDesigns {
    if (_selectedCategory == 'All') {
      return _designs;
    }
    return _designs.where((design) =>
    _getDesignCategory(design) == _selectedCategory).toList();
  }

  String _getDesignCategory(Design design) {
    final name = design.name.toLowerCase();
    if (name.contains('living') || name.contains('sofa')) return 'Living Room';
    if (name.contains('bed') || name.contains('bedroom')) return 'Bedroom';
    if (name.contains('kitchen')) return 'Kitchen';
    if (name.contains('office') || name.contains('desk')) return 'Office';
    if (name.contains('dining') || name.contains('table')) return 'Dining Room';
    if (name.contains('bath')) return 'Bathroom';
    return 'Uncategorized';
  }

  bool _hasImage(Design design) {
    return design.imageUrl != null && design.imageUrl!.isNotEmpty;
  }

  Future<void> _deleteDesignFromFirebase(Design design) async {
    try {
      // Delete from Firestore
      await _firestore.collection('designs').doc(design.id).delete();

      // Delete image from Storage if exists
      if (design.imageUrl != null && design.imageUrl!.contains('firebasestorage')) {
        try {
          final ref = _storage.refFromURL(design.imageUrl!);
          await ref.delete();
        } catch (e) {
          print('Error deleting image from storage: $e');
        }
      }

      await _loadDesignsFromFirebase();

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
            content: Text('Error deleting design: $e'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDesignsFromFirebase,
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

  Widget _buildDesignCard(Design design) {
    final hasImage = _hasImage(design);

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
                '${design.objects.length} items • ${_getDesignCategory(design)}',
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
                ? 'Create your first design to get started!'
                : 'No designs in the ${_selectedCategory} category',
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
          if (_selectedCategory != 'All')
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                });
              },
              child: const Text('View All Designs'),
            ),
        ],
      ),
    );
  }

  void _showDesignDetails(Design design) {
    final hasImage = _hasImage(design);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(design.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${_getDesignCategory(design)}'),
              Text('Project ID: ${design.projectId}'),
              Text('User ID: ${design.userId}'),
              Text('Date Created: ${_formatDate(design.createdAt)}'),
              Text('Last Updated: ${_formatDate(design.updatedAt)}'),
              Text('Objects: ${design.objects.length}'),
              const SizedBox(height: 16),

              // Display the actual saved image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple.withOpacity(0.2),
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
                  child: Icon(
                    Icons.photo,
                    size: 60,
                    color: AppColors.primaryLightPurple,
                  ),
                )
                    : null,
              ),

              const SizedBox(height: 16),
              if (design.objects.isNotEmpty) ...[
                Text(
                  'Objects in this design:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                ...design.objects.take(3).map((obj) =>
                    Text('• Item ID: ${obj.itemId}')
                ).toList(),
                if (design.objects.length > 3)
                  Text('... and ${design.objects.length - 3} more'),
              ],
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
              _viewDesign(design);
            },
            child: const Text('View Design'),
          ),
          IconButton(
            onPressed: () {
              _deleteDesign(design);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _viewDesign(Design design) {
    final hasImage = _hasImage(design);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: hasImage
              ? BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(design.imageUrl!),
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Design info overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

              // Fallback if no image
              if (!hasImage)
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

  void _deleteDesign(Design design) {
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
              await _deleteDesignFromFirebase(design);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}