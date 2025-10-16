import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:roomantics/views/pages/roomielab_gallery.dart';
import '/utils/colors.dart';

class RoomieLabScreen extends StatefulWidget {
  const RoomieLabScreen({super.key});

  @override
  State<RoomieLabScreen> createState() => _RoomieLabScreenState();
}

class _RoomieLabScreenState extends State<RoomieLabScreen> {
  String _htmlContent = '';
  List<Map<String, dynamic>> _recentDesigns = [];

  @override
  void initState() {
    super.initState();
    _loadHtmlContent();
    _loadRecentDesigns();
  }

  Future<void> _loadHtmlContent() async {
    try {
      String html = await rootBundle.loadString('assets/web/index.html');
      String css = await rootBundle.loadString('assets/web/css/style.css');
      String js = await rootBundle.loadString('assets/web/js/script.js');

      html = html.replaceFirst(
          '<link rel="stylesheet" href="css/style.css">',
          '<style>$css</style>'
      );

      html = html.replaceFirst(
          '<script src="js/script.js"></script>',
          '<script>$js</script>'
      );

      setState(() {
        _htmlContent = html;
      });
    } catch (e) {
      print('Error loading HTML: $e');
      setState(() {
        _htmlContent = '''
        <html>
          <body style="padding: 20px; font-family: Arial; background: #f5f5f5;">
            <h1 style="color: #6C63FF;">RoomieLab AR Studio & Gallery</h1>
            <p>Full AR studio with furniture catalog and design gallery</p>
            <div style="background: white; padding: 20px; border-radius: 10px; margin: 20px 0;">
              <h3 style="color: #6C63FF;">Features:</h3>
              <ul>
                <li>Furniture catalog with categories</li>
                <li>AR placement and manipulation</li>
                <li>Design gallery</li>
                <li>Save and manage projects</li>
              </ul>
            </div>
            <p><em>WebView integration coming soon</em></p>
          </body>
        </html>
        ''';
      });
    }
  }

  void _loadRecentDesigns() {
    // Mock data - will be replaced with actual gallery data
    setState(() {
      _recentDesigns = [
        {
          'id': '1',
          'name': 'Living Room Design',
          'category': 'Sofas',
          'date': '2023-12-01',
          'imageUrl': '',
        },
        {
          'id': '2',
          'name': 'Bedroom Setup',
          'category': 'Beds',
          'date': '2023-11-28',
          'imageUrl': '',
        },
        {
          'id': '3',
          'name': 'Office Space',
          'category': 'Chairs',
          'date': '2023-11-25',
          'imageUrl': '',
        },
        {
          'id': '4',
          'name': 'Dining Area',
          'category': 'Tables',
          'date': '2023-11-20',
          'imageUrl': '',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoomieLab AR Studio'),
        backgroundColor: AppColors.primaryLightPurple,
        foregroundColor: Colors.white,
      ),
      body: _htmlContent.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildWebViewAlternative(),
    );
  }

  Widget _buildWebViewAlternative() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions - FIXED: Equal sized cards
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
                  icon: Icons.camera_alt,
                  title: 'Open Camera',
                  subtitle: 'Quick AR view',
                  onTap: () {
                    Navigator.pushNamed(context, '/camera_page');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.photo_library,
                  title: 'My Gallery',
                  subtitle: 'View designs',
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

          const SizedBox(height: 20),

          // Furniture Categories
          Text(
            'Furniture Categories',
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
            children: [
              'Sofas', 'Chairs', 'Tables', 'Beds', 'Lighting', 'Decor'
            ].map((category) {
              return Chip(
                label: Text(category),
                backgroundColor: AppColors.primaryLightPurple.withOpacity(0.1),
                labelStyle: TextStyle(color: AppColors.primaryLightPurple),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Recent Designs - Now pulls from gallery
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
      ),
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
          height: 120, // Fixed height for equal cards
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

  Widget _buildDesignCard(Map<String, dynamic> design) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to design details
          _showDesignDetails(design);
        },
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
                ),
                child: Icon(
                  Icons.photo,
                  size: 40,
                  color: AppColors.primaryLightPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                design['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                design['category'],
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                design['date'],
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
            'No designs yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your first AR design to see it here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showDesignDetails(Map<String, dynamic> design) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(design['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${design['category']}'),
            Text('Date: ${design['date']}'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.photo,
                size: 60,
                color: AppColors.primaryLightPurple,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open in AR functionality
            },
            child: Text('View Design'),
          ),
        ],
      ),
    );
  }
}