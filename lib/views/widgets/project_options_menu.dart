import 'package:flutter/material.dart';
import 'package:Roomantics/utils/colors.dart';

class ProjectOptionsMenu extends StatelessWidget {
  final String projectId;
  final VoidCallback onViewFullScreen;
  final VoidCallback onEditProject;
  final VoidCallback? onEditName;
  final VoidCallback? onManageCollaborators;
  final VoidCallback onDeleteProject;

  const ProjectOptionsMenu({
    super.key,
    required this.projectId,
    required this.onViewFullScreen,
    required this.onEditProject,
     this.onEditName,
     this.onManageCollaborators,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context).withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.more_vert,
          color: AppColors.getTextColor(context),
          size: 20,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewFullScreen();
            break;
          case 'edit':
            onEditProject();
            break;
          case 'edit_name':
            onEditName?.call();
            break;
          case 'collaborators':
            onManageCollaborators?.call();
            break;
          case 'delete':
            onDeleteProject();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.fullscreen, color: AppColors.getTextColor(context)),
              const SizedBox(width: 8),
              Text('View Full Screen'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.getTextColor(context)),
              const SizedBox(width: 8),
              Text('Edit Project'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit_name',
          child: Row(
            children: [
              Icon(Icons.title, color: AppColors.getTextColor(context)),
              const SizedBox(width: 8),
              Text('Rename Project'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'collaborators',
          child: Row(
            children: [
              Icon(Icons.people, color: AppColors.getTextColor(context)),
              const SizedBox(width: 8),
              Text('Manage Collaborators'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Delete Project',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}