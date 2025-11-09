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

// Main page to display user's saved Roomantics projects
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    // Ensures projects are loaded after the first build is complete,
    // so we have a valid context for Provider access.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      viewModel.loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the RoomieLabViewModel for loading, error, and project data changes
    final viewModel = Provider.of<RoomieLabViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadProjects(),
          ),
        ],
      ),
      
      // FAB to start the camera and create a new project
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera-page');
        },
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add_a_photo, color: AppColors.white),
      ),
      body: Consumer<RoomieLabViewModel>(
        builder: (context, viewModel, child) {
          
          // Show loading spinner only if we're still loading and have 0 projects
          if (viewModel.isLoading && viewModel.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if there's a loading failure and no projects to show
          if (viewModel.errorMessage != null && viewModel.projects.isEmpty) {
            return _buildErrorState(context, viewModel);
          }

          // Show the grid of projects, or empty state if none
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: viewModel.projects.isEmpty
                ? _buildEmptyState(context)
                : Padding(
              padding: const EdgeInsets.all(12.0),
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadProjects(),
                child: GridView.builder(
                  key: const ValueKey('projectGrid'),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: viewModel.projects.length,
                  itemBuilder: (context, index) {
                    final project = viewModel.projects[index];
                    return _AnimatedProjectCard(
                      key: ValueKey(project.id),
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

  // When no projects are available, show a prominent empty state message and button
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

  // Show an error message (with retry option) if there's a loading failure and no data
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
          ElevatedButton(
            onPressed: () => viewModel.loadProjects(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Individual card for each project in the grid, with animation when appearing
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

    // Setup animation for project card entry
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  // Main project image (network or local file, with placeholder fallback)
                  Expanded(
                    flex: 7,
                    child: _buildProjectImage(imageUrl),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
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
                              Text(
                                _formatDate(project.createdAt),
                                style: TextStyle(
                                  color: AppColors.getSecondaryTextColor(context),
                                  fontSize: 12,
                                ),
                              ),
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

              // Project options menu (view, edit, delete)
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
                      '${project.items.length}',
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

  // Helper to display the right type of image for each project,
  // or a fallback if not available.
  Widget _buildProjectImage(String? imageUrl) {
    final isCloudinaryUrl = imageUrl?.contains('cloudinary.com') ?? false;
    final isLocalFile = imageUrl?.startsWith('/') ?? false;

    if (imageUrl == null) {
      return _buildPlaceholderImage(Icons.photo_library, 'No Image');
    }

    if (isCloudinaryUrl) {
      // Load from Cloudinary URL
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
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
    } else if (isLocalFile && File(imageUrl).existsSync()) {
      // Load from local file
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
    } else {
      // Fallback to placeholder
      return _buildPlaceholderImage(Icons.image_not_supported, 'Invalid image');
    }
  }

  // Reusable placeholder if project image is missing or format is invalid
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

  // Navigation actions for project card's context menu
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

  // Deletes a project after showing a confirmation dialog
  Future<void> _deleteProject(BuildContext context, Project project) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project?'),
          content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await widget.viewModel.deleteProject(project.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
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

  // Format the project's date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
