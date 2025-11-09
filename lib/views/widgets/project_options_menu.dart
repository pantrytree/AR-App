import 'package:flutter/material.dart';
import 'package:Roomantics/utils/colors.dart';

// ProjectOptionsMenu is a reusable popup menu component for project actions
// Provides a consistent interface for project-related operations across the app
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
      // Custom styled menu icon
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context).withOpacity(0.9), // Semi-transparent background
          shape: BoxShape.circle, // Circular button
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Subtle shadow for depth
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.more_vert, // Vertical ellipsis icon
          color: AppColors.getTextColor(context), // Dynamic color based on theme
          size: 20, // Appropriate size for touch targets
        ),
      ),
      // Handle menu item selection
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewFullScreen(); // Navigate to full-screen view
            break;
          case 'edit':
            onEditProject(); // Navigate to project editor
            break;
          case 'edit_name':
            onEditName?.call(); //Open rename dialog
            break;
          case 'collaborators':
            onManageCollaborators?.call(); // Open collaborators management
            break;
          case 'delete':
            onDeleteProject(); // Initiate project deletion
            break;
        }
      },
      // Build the menu items
      itemBuilder: (BuildContext context) => [
        // Full Screen View option
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.fullscreen, color: AppColors.getTextColor(context)),
              const SizedBox(width: 8), // Spacing between icon and text
              Text('View Full Screen'), // Action label
            ],
          ),
        ),
        // Edit Project option
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
        // Rename Project option 
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
        // Manage Collaborators option
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
        // Delete Project option (destructive action)
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red), // Red color for destructive action
              const SizedBox(width: 8),
              Text(
                'Delete Project',
                style: TextStyle(color: Colors.red), // Red text for emphasis
              ),
            ],
          ),
        ),
      ],
    );
  }
}
