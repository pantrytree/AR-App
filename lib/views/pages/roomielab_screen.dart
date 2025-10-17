import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomantics/models/design.dart'; // Make sure this import is correct
import 'package:roomantics/views/pages/roomielab_gallery.dart';
import 'package:roomantics/views/pages/roomielab_page.dart';
import '../../models/design_object.dart';
import '/utils/colors.dart';

class RoomieLabScreen extends StatefulWidget {
  const RoomieLabScreen({super.key});

  @override
  State<RoomieLabScreen> createState() => _RoomieLabScreenState();
}

class _RoomieLabScreenState extends State<RoomieLabScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Design> _recentDesigns = [];
  List<String> _categories = [];
  bool _isLoading = true;

  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _loadRecentDesigns();
    _loadCategories();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadRecentDesigns() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(4)
          .get();

      final designs = querySnapshot.docs.map((doc) {
        return Design.fromFirestore(doc);
      }).toList();

      setState(() {
        _recentDesigns = designs;
      });
    } catch (e) {
      print('Error loading recent designs: $e');
      _loadRecentDesignsAlternative();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentDesignsAlternative() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(4)
          .get();

      final designs = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Design(
          id: doc.id,
          userId: data['userId'] ?? '',
          projectId: data['projectId'] ?? '',
          name: data['name'] ?? 'Untitled Design',
          objects: _parseDesignObjects(data['objects']),
          imageUrl: data['imageUrl'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );
      }).toList();

      setState(() {
        _recentDesigns = designs;
      });
    } catch (e) {
      print('Error in alternative design loading: $e');
    }
  }

  List<DesignObject> _parseDesignObjects(dynamic objectsData) {
    if (objectsData == null) return [];
    if (objectsData is! List) return [];

    return objectsData.map((obj) {
      if (obj is Map<String, dynamic>) {
        return DesignObject(
          itemId: obj['itemId'] ?? '',
          position: Position(
            x: (obj['position']?['x'] ?? 0).toDouble(),
            y: (obj['position']?['y'] ?? 0).toDouble(),
            z: (obj['position']?['z'] ?? 0).toDouble(),
          ),
          rotation: Rotation(
            x: (obj['rotation']?['x'] ?? 0).toDouble(),
            y: (obj['rotation']?['y'] ?? 0).toDouble(),
            z: (obj['rotation']?['z'] ?? 0).toDouble(),
          ),
          scale: Scale(
            x: (obj['scale']?['x'] ?? 1.0).toDouble(),
            y: (obj['scale']?['y'] ?? 1.0).toDouble(),
            z: (obj['scale']?['z'] ?? 1.0).toDouble(),
          ),
        );
      }
      return DesignObject(
        itemId: '',
        position: Position(x: 0, y: 0, z: 0),
        rotation: Rotation(x: 0, y: 0, z: 0),
        scale: Scale(x: 1.0, y: 1.0, z: 1.0),
      );
    }).toList();
  }

  Future<void> _loadCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      setState(() {
        _categories = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback categories
      _categories = ['Living Room', 'Bedroom', 'Kitchen', 'Office', 'Dining Room', 'Bathroom'];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoomieLab AR Studio'),
        backgroundColor: AppColors.primaryLightPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadRecentDesigns();
              _loadCategories();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 20),

          // Furniture Categories
          _buildCategories(),
          const SizedBox(height: 20),

          // Recent Designs
          _buildRecentDesigns(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A44B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RoomieLab AR Studio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Full-featured AR furniture studio and design gallery',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildStatChip('${_recentDesigns.length} Designs', Icons.photo_library),
              _buildStatChip('${_categories.length} Categories', Icons.category),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryLightPurple),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: AppColors.primaryLightPurple)),
        ],
      ),
      backgroundColor: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.view_in_ar,
                title: 'AR Studio',
                subtitle: 'Manage projects',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomieLabPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.photo_library,
                title: 'Design Gallery',
                subtitle: 'View saved designs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomieLabGallery(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((category) {
            return Chip(
              label: Text(category),
              backgroundColor: AppColors.primaryLightPurple.withOpacity(0.1),
              labelStyle: TextStyle(color: AppColors.primaryLightPurple),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentDesigns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Designs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomieLabGallery(),
                  ),
                );
              },
              child: Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentDesigns.isEmpty
            ? _buildEmptyGalleryState()
            : _buildDesignGrid(),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.primaryLightPurple),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _recentDesigns.length,
      itemBuilder: (context, index) {
        final design = _recentDesigns[index];
        return _buildDesignCard(design);
      },
    );
  }

  Widget _buildDesignCard(Design design) {
    final hasImage = design.imageUrl != null && design.imageUrl!.isNotEmpty;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showDesignOptions(design),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
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
                    ? Icon(
                  Icons.photo,
                  size: 40,
                  color: AppColors.primaryLightPurple,
                )
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                design.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getDesignCategory(design),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(design.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${design.objects.length} items',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryLightPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGalleryState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: AppColors.getSecondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No designs yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first AR design to see it here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera-page');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create First Design'),
          ),
        ],
      ),
    );
  }

  void _showDesignOptions(Design design) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.primaryLightPurple),
                title: Text('View in Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomieLabGallery(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.primaryLightPurple),
                title: Text('Open in AR Studio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomieLabPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}