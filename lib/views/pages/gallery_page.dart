import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomantics/theme/theme.dart';
import 'package:roomantics/utils/colors.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/views/widgets/project_options_menu.dart';
import 'package:roomantics/views/pages/project_full_screen_page.dart';
import 'package:roomantics/views/pages/project_edit_page.dart';

class RoomieLabPage extends StatelessWidget {
  const RoomieLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RoomieLabViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RoomieLab',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera_page');
        },
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add_a_photo, color: AppColors.white),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: viewModel.savedProjects.isEmpty
            ? _buildEmptyState(context)
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            key: const ValueKey('projectGrid'),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: viewModel.savedProjects.length,
            itemBuilder: (context, index) {
              final project = viewModel.savedProjects[index];
              return _AnimatedProjectCard(
                key: ValueKey(project['id']),
                project: project,
                viewModel: viewModel,
              );
            },
          ),
        ),
      ),
    );
  }

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
          Text(
            'Capture and save your designs using the camera.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
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
    final imagePath = project['imagePath'];
    final furniture = project['furniture'];

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
                      child: imagePath != null && File(imagePath).existsSync()
                          ? ClipRRect(
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                          : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Container(
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
                            furniture ?? "Unnamed Project",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(DateTime.parse(project['timestamp'])),
                            style: TextStyle(
                              color: AppColors.getSecondaryTextColor(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3-Dot Options Menu Button
            Positioned(
              top: 8,
              right: 8,
              child: ProjectOptionsMenu(
                projectId: project['id'],
                onViewFullScreen: () => _navigateToFullScreen(context, project),
                onEditProject: () => _navigateToEditProject(context, project),
                onDeleteProject: () => widget.viewModel.deleteProjectById(project['id']),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFullScreen(BuildContext context, Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectFullScreenPage(project: project),
      ),
    );
  }

  void _navigateToEditProject(BuildContext context, Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectEditPage(project: project),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}