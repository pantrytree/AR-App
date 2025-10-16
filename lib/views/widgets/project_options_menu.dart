import 'package:flutter/material.dart';

/// 3-dot options menu for saved projects
/// Provides: View Full Screen, Edit Project, Delete Project options
class ProjectOptionsMenu extends StatelessWidget {
  final String projectId;
  final VoidCallback onViewFullScreen;
  final VoidCallback onEditProject;
  final VoidCallback onDeleteProject;

  const ProjectOptionsMenu({
    super.key,
    required this.projectId,
    required this.onViewFullScreen,
    required this.onEditProject,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) => [
        // View Full Screen Option
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.fullscreen, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('View Full Screen'),
            ],
          ),
        ),
        // Edit Project Option
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.orange),
              SizedBox(width: 8),
              Text('Edit Project'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Delete Project Option
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Project'),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'view':
            onViewFullScreen();
            break;
          case 'edit':
            onEditProject();
            break;
          case 'delete':
            _showDeleteConfirmationDialog(context);
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.more_vert,
          size: 18,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// Shows confirmation dialog before deleting project
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteProject();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}