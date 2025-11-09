import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/theme/theme.dart';
import 'package:Roomantics/utils/colors.dart';
import 'package:Roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:Roomantics/views/widgets/project_options_menu.dart';
import 'package:Roomantics/views/pages/project_full_screen_page.dart';
import 'package:Roomantics/views/pages/project_edit_page.dart';
import '../../viewmodels/camera_viewmodel.dart';
import '/models/project.dart';

// GalleryPage displays a collection of user's AR projects in a grid layout
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    // Load projects after the widget is built to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      viewModel.loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RoomieLabViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0, // Remove app bar shadow
        actions: [
          // Refresh button to reload projects
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadProjects(),
          ),
        ],
      ),
      // Floating action button to navigate to camera page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera-page');
        },
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add_a_photo, color: AppColors.white),
      ),
      body: Consumer<RoomieLabViewModel>(
        builder: (context, viewModel, child) {
          // Show loading indicator only on initial load
          if (viewModel.isLoading && viewModel.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error state if there's an error and no projects
          if (viewModel.errorMessage != null && viewModel.projects.isEmpty) {
            return _buildErrorState(context, viewModel);
          }

          // Animated switcher for smooth transitions between states
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: viewModel.projects.isEmpty
                ? _buildEmptyState(context) // Show empty state when no projects
                : Padding(
              padding: const EdgeInsets.all(12.0),
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadProjects(), // Pull-to-refresh
                child: GridView.builder(
                  key: const ValueKey('projectGrid'),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2-column grid
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8, // Card aspect ratio
                  ),
                  itemCount: viewModel.projects.length,
                  itemBuilder: (context, index) {
                    final project = viewModel.projects[index];
                    return _AnimatedProjectCard(
                      key: ValueKey(project.id), // Unique key for animations
                      project: project,
                      viewModel: viewModel,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build empty state when user has no projects
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      key: const ValueKey('emptyState'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_work_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'No projects yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Capture and save your designs using the camera.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Call-to-action button to create first project
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/camera-page');
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Create First Project'),
          ),
        ],
      ),
    );
  }

  // Build error state when projects fail to load
  Widget _buildErrorState(BuildContext context, RoomieLabViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load projects',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              viewModel.errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Retry button to attempt loading again
          ElevatedButton(
            onPressed: () => viewModel.loadProjects(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Animated project card with scale and fade animations
class _AnimatedProjectCard extends StatefulWidget {
  final Project project;
  final RoomieLabViewModel viewModel;

  const _AnimatedProjectCard({
    super.key,
    required this.project,
    required this.viewModel,
  });

  @override
  State<_AnimatedProjectCard> createState() => _AnimatedProjectCardState();
}

class _AnimatedProjectCardState extends State<_AnimatedProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Bouncy scale effect
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // Smooth fade in
    );

    // Start animation when widget is created
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final imageUrl = project.imageUrl;
    final projectName = project.name;

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section 
                  Expanded(
                    flex: 7,
                    child: _buildProjectImage(imageUrl),
                  ),
                  // Info section 
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1), // Subtle purple background
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Project name
                          Text(
                            projectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Creation date
                              Text(
                                _formatDate(project.createdAt),
                                style: TextStyle(
                                  color: AppColors.getSecondaryTextColor(context),
                                  fontSize: 12,
                                ),
                              ),
                              // Room type 
                              if (project.roomType.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  project.roomType,
                                  style: TextStyle(
                                    color: AppColors.getSecondaryTextColor(context),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Options menu 
              Positioned(
                top: 8,
                right: 8,
                child: ProjectOptionsMenu(
                  projectId: project.id,
                  onViewFullScreen: () => _navigateToFullScreen(context, project),
                  onEditProject: () => _navigateToEditProject(context, project),
                  onDeleteProject: () => _deleteProject(context, project),
                ),
              ),

              // Items count badge 
              if (project.items.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${project.items.length}', // Number of furniture items in project
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build project image with fallback handling
  Widget _buildProjectImage(String? imageUrl) {
    final isCloudinaryUrl = imageUrl?.contains('cloudinary.com') ?? false;
    final isLocalFile = imageUrl?.startsWith('/') ?? false;

    // Show placeholder if no image URL
    if (imageUrl == null) {
      return _buildPlaceholderImage(Icons.photo_library, 'No Image');
    }

    // Handle Cloudinary URLs (cloud storage)
    if (isCloudinaryUrl) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            // Show progress indicator while loading
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(Icons.broken_image, 'Failed to load');
          },
        ),
      );
    } 
    // Handle local file paths
    else if (isLocalFile && File(imageUrl).existsSync()) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(Icons.broken_image, 'File error');
          },
        ),
      );
    } 
    // Fallback for invalid or unsupported image URLs
    else {
      return _buildPlaceholderImage(Icons.image_not_supported, 'Invalid image');
    }
  }

  // Build placeholder image when actual image is unavailable
  Widget _buildPlaceholderImage(IconData icon, String text) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to full-screen project view
  void _navigateToFullScreen(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectFullScreenPage(
          projectId: project.id,
        ),
      ),
    );
  }

  // Navigate to project editing page
  void _navigateToEditProject(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: Provider.of<CameraViewModel>(context, listen: false),
          child: ProjectEditPage(
            projectId: project.id,
            initialDesignId: null,
          ),
        ),
      ),
    );
  }

  // Delete project with confirmation dialog
  Future<void> _deleteProject(BuildContext context, Project project) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project?'),
          content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm delete
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // Proceed with deletion if user confirmed
    if (shouldDelete == true) {
      try {
        await widget.viewModel.deleteProject(project.id);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // Show error message if deletion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete project: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Format date as DD/MM/YYYY
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
