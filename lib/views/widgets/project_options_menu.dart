import 'package:flutter/material.dart';
import 'package:roomantics/utils/colors.dart';

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
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context).withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.more_vert, size: 16),
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewFullScreen();
            break;
          case 'edit':
            onEditProject();
            break;
          case 'delete':
            onDeleteProject();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.fullscreen, size: 20),
              SizedBox(width: 8),
              Text('View Full Screen'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit Project'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}