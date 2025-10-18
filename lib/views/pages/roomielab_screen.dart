import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Roomantics/models/design.dart';
import 'package:Roomantics/views/pages/roomielab_gallery.dart';
import 'package:Roomantics/views/pages/roomielab_page.dart';
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
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadRecentDesigns(),
      _loadCategories(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadRecentDesigns() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _recentDesigns = [];
        });
        return;
      }

      print('Loading recent designs for user: ${user.uid}');

      final querySnapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: user.uid)
          .orderBy('lastViewed', descending: true)
          .limit(6)
          .get();

      print('Found ${querySnapshot.docs.length} design documents');

      final designs = <Design>[];
      for (final doc in querySnapshot.docs) {
        try {
          final design = Design.fromFirestore(doc);
          designs.add(design);
        } catch (e) {
          print('Error parsing design ${doc.id}: $e');
        }
      }

      final recentDesigns = designs.take(4).toList();

      if (mounted) {
        setState(() {
          _recentDesigns = recentDesigns;
          _isLoading = false;
        });
      }

      print('Loaded ${_recentDesigns.length} recent designs');
    } catch (e) {
      print('Error loading recent designs: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _recentDesigns = [];
        });
      }
    }
  }

  Future<Design?> _parseDesignFromDoc(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      Timestamp? createdAt;
      Timestamp? updatedAt;
      Timestamp? lastViewed;

      try {
        createdAt = data['createdAt'] as Timestamp?;
        updatedAt = data['updatedAt'] as Timestamp?;
        lastViewed = data['lastViewed'] as Timestamp?;
      } catch (e) {
        print('Error parsing timestamps for design ${doc.id}: $e');
      }

      final lastViewedTime = lastViewed?.toDate() ?? DateTime.now();

      return Design(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        projectId: data['projectId']?.toString() ?? '',
        name: data['name']?.toString() ?? 'Untitled Design',
        objects: _parseDesignObjects(data['objects']),
        imageUrl: data['imageUrl']?.toString(),
        createdAt: createdAt?.toDate() ?? DateTime.now(),
        updatedAt: updatedAt?.toDate() ?? DateTime.now(),
        lastViewed: lastViewedTime,
      );
    } catch (e) {
      print('Failed to parse design ${doc.id}: $e');
      return null;
    }
  }

  List<DesignObject> _parseDesignObjects(dynamic objectsData) {
    if (objectsData == null) return [];
    if (objectsData is! List) return [];

    final objects = <DesignObject>[];
    for (final obj in objectsData) {
      if (obj is Map<String, dynamic>) {
        try {
          final designObject = DesignObject(
            itemId: obj['itemId']?.toString() ?? '',
            position: Position(
              x: _parseDouble(obj['position']?['x']) ?? 0.0,
              y: _parseDouble(obj['position']?['y']) ?? 0.0,
              z: _parseDouble(obj['position']?['z']) ?? 0.0,
            ),
            rotation: Rotation(
              x: _parseDouble(obj['rotation']?['x']) ?? 0.0,
              y: _parseDouble(obj['rotation']?['y']) ?? 0.0,
              z: _parseDouble(obj['rotation']?['z']) ?? 0.0,
            ),
            scale: Scale(
              x: _parseDouble(obj['scale']?['x']) ?? 1.0,
              y: _parseDouble(obj['scale']?['y']) ?? 1.0,
              z: _parseDouble(obj['scale']?['z']) ?? 1.0,
            ),
          );
          objects.add(designObject);
        } catch (e) {
          print('Error parsing design object: $e');
        }
      }
    }
    return objects;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Track when a design is viewed
  Future<void> _trackDesignView(String designId) async {
    try {
      await _firestore.collection('designs').doc(designId).update({
        'lastViewed': FieldValue.serverTimestamp(),
      });
      print('Tracked view for design: $designId');
    } catch (e) {
      print('Error tracking design view: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

      final names = <String>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final dynamic n = data['name'];

        if (n is String && n.trim().isNotEmpty) {
          names.add(n.trim());
        } else {
          final altName = data['category'] ?? data['title'] ?? data['label'];
          if (altName is String && altName.trim().isNotEmpty) {
            names.add(altName.trim());
          } else {
            print('Category doc ${doc.id} has invalid or missing name: $data');
          }
        }
      }

      if (names.isEmpty) {
        names.addAll(['Living Room', 'Bedroom', 'Kitchen', 'Office', 'Dining Room', 'Bathroom']);
      }

      if (mounted) {
        setState(() {
          _categories = names;
        });
      }
      print('Loaded ${names.length} categories from Firestore.');
    } catch (e, st) {
      print('Error loading categories: $e\n$st');
      if (mounted) {
        setState(() {
          _categories = ['Living Room', 'Bedroom', 'Kitchen', 'Office', 'Dining Room', 'Bathroom'];
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    return '${(difference.inDays / 30).floor()}mo ago';
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
          _buildHeader(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildCategories(),
          const SizedBox(height: 20),
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
              _buildStatChip('${_recentDesigns.length} Recent Designs', Icons.photo_library),
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
                subtitle: 'Create new designs',
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
                subtitle: 'View all designs',
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
              'Recently Viewed Designs',
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
        childAspectRatio: 0.85,
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
        onTap: () {
          // Track the design view and navigate
          _trackDesignView(design.id);
          _showDesignOptions(design);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Design Image
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

              // Design Name
              Text(
                design.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Category
              Text(
                _getDesignCategory(design),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),

              // Last Viewed Time
              Text(
                _formatTimeAgo(design.lastViewed),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryLightPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              // Items Count
              Text(
                '${design.objects.length} items',
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
            'No recent designs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create or view designs to see them here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomieLabPage(),
                ),
              );
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
              ListTile(
                leading: Icon(Icons.refresh, color: AppColors.primaryLightPurple),
                title: Text('Mark as Viewed'),
                onTap: () {
                  Navigator.pop(context);
                  _trackDesignView(design.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Design marked as viewed'),
                      duration: Duration(seconds: 2),
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