import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/theme/theme.dart';
import '/utils/colors.dart';
import '/viewmodels/roomielab_viewmodel.dart';
import '/views/widgets/project_options_menu.dart';
import '/views/pages/project_full_screen_page.dart';
import '/views/pages/project_edit_page.dart';
import '/models/project.dart';

class RoomieLabPage extends StatefulWidget {
  const RoomieLabPage({super.key});

  @override
  State<RoomieLabPage> createState() => _RoomieLabPageState();
}

class _RoomieLabPageState extends State<RoomieLabPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      viewModel.loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'RoomieLab',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0,
        actions: [
          Consumer<RoomieLabViewModel>(
            builder: (context, viewModel, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => viewModel.loadProjects(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/camera-page');
        },
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add_a_photo, color: AppColors.white),
        label: const Text(
          'New Project',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: Consumer<RoomieLabViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () => viewModel.loadProjects(),
            child: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, RoomieLabViewModel viewModel) {
    // Show error messages
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () => viewModel.clearError(),
              ),
            ),
          );
          viewModel.clearError();
        }
      });
    }

    if (viewModel.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          viewModel.clearSuccess();
        }
      });
    }

    if (viewModel.isLoading && viewModel.projects.isEmpty) {
      return _buildLoadingState(context);
    }

    if (viewModel.projects.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildProjectsGrid(context, viewModel);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.getPrimaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your projects...',
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      key: const ValueKey('emptyState'),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 100,
              color: AppColors.getSecondaryTextColor(context).withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Create your first AR design by tapping the button below',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.getSecondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/camera-page');
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, RoomieLabViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        key: const ValueKey('projectGrid'),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
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
    );
  }
}

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

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            // Project Card
            GestureDetector(
              onTap: () => _navigateToFullScreen(context, project),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildProjectImage(context, project),
                    ),
                    _buildProjectInfo(context, project),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: ProjectOptionsMenu(
                projectId: project.id,
                onViewFullScreen: () => _navigateToFullScreen(context, project),
                onEditProject: () => _navigateToEditProject(context, project),
                onDeleteProject: () => _confirmDelete(context, project),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectImage(BuildContext context, Project project) {
    if (project.imageUrl != null && project.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          project.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primaryPurple,
              ),
            );
          },
        ),
      );
    }

    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context, Project project) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.getTextColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            project.roomType,
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(project.createdAt),
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

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
        builder: (context) => ProjectEditPage(
          projectId: project.id,
          furnitureItemId: project.items.isNotEmpty ? project.items.first : '',
          furnitureName: project.name,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Delete Project',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final success = await widget.viewModel.deleteProject(project.id);

              if (context.mounted) {
                Navigator.pop(context);
              }

              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.viewModel.errorMessage ?? 'Failed to delete project',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}