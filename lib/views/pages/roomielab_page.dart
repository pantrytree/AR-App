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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      viewModel.loadProjects();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    return _buildProjectsList(context, viewModel);
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

  Widget _buildProjectsList(BuildContext context, RoomieLabViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic height based on screen size
        final cardHeight = constraints.maxHeight * 0.65; // 65% of available height

        return ListView.builder(
          key: const ValueKey('projectList'),
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.projects.length,
          itemBuilder: (context, index) {
            final project = viewModel.projects[index];
            return _AnimatedProjectCard(
              key: ValueKey(project.id),
              project: project,
              viewModel: viewModel,
              cardHeight: cardHeight,
            );
          },
        );
      },
    );
  }
}

class _AnimatedProjectCard extends StatefulWidget {
  final Project project;
  final RoomieLabViewModel viewModel;
  final double cardHeight;

  const _AnimatedProjectCard({
    super.key,
    required this.project,
    required this.viewModel,
    required this.cardHeight,
  });

  @override
  State<_AnimatedProjectCard> createState() => _AnimatedProjectCardState();
}

class _AnimatedProjectCardState extends State<_AnimatedProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;
  bool _isLiked = false;
  int _likeCount = 0;

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

    _isLiked = widget.project.isLiked ?? false;
    _likeCount = widget.project.likeCount ?? 0;

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() async {
    setState(() {
      if (_isLiked) {
        _likeCount--;
      } else {
        _likeCount++;
      }
      _isLiked = !_isLiked;
    });

    final success = await widget.viewModel.toggleProjectLike(widget.project.id);
    if (!success && mounted) {
      // Revert if failed
      setState(() {
        if (_isLiked) {
          _likeCount--;
        } else {
          _likeCount++;
        }
        _isLiked = !_isLiked;
      });
    }
  }

  void _showCollaboratorsDialog() {
    showDialog(
      context: context,
      builder: (context) => _CollaboratorsDialog(
        project: widget.project,
        viewModel: widget.viewModel,
      ),
    );
  }

  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: widget.project.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Edit Project Name',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter project name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final success = await widget.viewModel.updateProjectName(
                  widget.project.id,
                  nameController.text.trim(),
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Project name updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          height: widget.cardHeight,
          margin: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // Main Project Card
              GestureDetector(
                onTap: () => _navigateToFullScreen(context, project),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getCardBackground(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Project Image - Dynamic height
                      Expanded(
                        flex: 3,
                        child: _buildProjectImage(context, project),
                      ),

                      // Project Info and Actions - Dynamic height
                      Expanded(
                        flex: 1,
                        child: _buildProjectInfoAndActions(context, project),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Options Menu
              Positioned(
                top: 12,
                right: 12,
                child: ProjectOptionsMenu(
                  projectId: project.id,
                  onViewFullScreen: () => _navigateToFullScreen(context, project),
                  onEditProject: () => _navigateToEditProject(context, project),
                  onEditName: _showEditNameDialog,
                  onManageCollaborators: _showCollaboratorsDialog,
                  onDeleteProject: () => _confirmDelete(context, project),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectImage(BuildContext context, Project project) {
    if (project.imageUrl != null && project.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            Image.network(
              project.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
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

            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
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
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildProjectInfoAndActions(BuildContext context, Project project) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return Container(
          padding: EdgeInsets.all(availableHeight * 0.1), // Dynamic padding based on available height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Project Name and Date - Dynamic sizing
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        project.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _calculateTitleFontSize(availableHeight),
                          color: AppColors.getTextColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: availableHeight * 0.05),
                    Text(
                      '${project.roomType} • ${_formatDate(project.createdAt)}',
                      style: TextStyle(
                        color: AppColors.getSecondaryTextColor(context),
                        fontSize: _calculateSubtitleFontSize(availableHeight),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action Buttons - Dynamic sizing
              SizedBox(height: availableHeight * 0.1),
              _buildActionButtons(context, availableHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, double availableHeight) {
    final project = widget.project;
    final buttonSize = availableHeight * 0.4; // Dynamic button size

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Like Button
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: '$_likeCount',
          color: _isLiked ? Colors.red : AppColors.getSecondaryTextColor(context),
          onTap: _toggleLike,
          size: buttonSize,
        ),

        // Collaborators Button
        _buildActionButton(
          icon: Icons.people_outline,
          label: '${project.collaborators?.length ?? 0}',
          color: AppColors.getSecondaryTextColor(context),
          onTap: _showCollaboratorsDialog,
          size: buttonSize,
        ),

        // Share Button
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          color: AppColors.getSecondaryTextColor(context),
          onTap: () => _shareProject(context, project),
          size: buttonSize,
        ),

        // Edit Button
        _buildActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: AppColors.getSecondaryTextColor(context),
          onTap: () => _navigateToEditProject(context, project),
          size: buttonSize,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: size * 0.45, // Dynamic icon size
            ),
          ),
          SizedBox(height: size * 0.1),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: _calculateButtonFontSize(size),
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic font size calculations
  double _calculateTitleFontSize(double availableHeight) {
    // Base size for normal screens, scales with available height
    return 16.0 + (availableHeight * 0.01);
  }

  double _calculateSubtitleFontSize(double availableHeight) {
    return 12.0 + (availableHeight * 0.005);
  }

  double _calculateButtonFontSize(double buttonSize) {
    return 10.0 + (buttonSize * 0.02);
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

  void _shareProject(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Share Project',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Share "${project.name}" with others via link or invite collaborators.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCollaboratorsDialog();
            },
            child: Text(
              'Invite Collaborators',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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

class _CollaboratorsDialog extends StatefulWidget {
  final Project project;
  final RoomieLabViewModel viewModel;

  const _CollaboratorsDialog({
    required this.project,
    required this.viewModel,
  });

  @override
  State<_CollaboratorsDialog> createState() => _CollaboratorsDialogState();
}

class _CollaboratorsDialogState extends State<_CollaboratorsDialog> {
  final TextEditingController _emailController = TextEditingController();
  List<String> collaborators = [];

  @override
  void initState() {
    super.initState();
    collaborators = widget.project.collaborators ?? [];
  }

  void _addCollaborator() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final success = await widget.viewModel.addCollaborator(
      widget.project.id,
      email,
    );

    if (success && mounted) {
      setState(() {
        collaborators.add(email);
        _emailController.clear();
      });
    }
  }

  void _removeCollaborator(String email) async {
    final success = await widget.viewModel.removeCollaborator(
      widget.project.id,
      email,
    );

    if (success && mounted) {
      setState(() {
        collaborators.remove(email);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.getCardBackground(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Project Collaborators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),
              const SizedBox(height: 16),

              // Add collaborator input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter email address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _addCollaborator(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.primaryPurple),
                    onPressed: _addCollaborator,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Collaborators list
              if (collaborators.isNotEmpty) ...[
                Text(
                  'Current Collaborators:',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: collaborators.length,
                    itemBuilder: (context, index) {
                      final email = collaborators[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                          radius: 20,
                          child: Icon(Icons.person, color: AppColors.primaryPurple, size: 16),
                        ),
                        title: Text(
                          email,
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red, size: 20),
                          onPressed: () => _removeCollaborator(email),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No collaborators yet',
                    style: TextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Close button
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}