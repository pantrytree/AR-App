import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/my_projects_viewmodel.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_components.dart';
import '../../../views/widgets/bottom_nav_bar.dart';
import '../../../views/pages/my_likes_page.dart';
import '../../../views/pages/camera_page(demo-shae).dart';


/// Displays the user's saved design projects.
/// Allows creation, editing, and deletion of projects, and navigation into the camera tool.



/// TODO (Backend Integration Notes):
/// - Replace mock project data in `MyProjectsViewModel` with backend API calls.
/// - Connect navigation destinations (e.g., camera page, explore page) once routes are finalized.
/// - Add thumbnail or project preview images when backend data supports it.
class MyProjectsPage extends StatefulWidget {
  const MyProjectsPage({super.key});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load projects once the UI has built
      Provider.of<MyProjectsViewModel>(context, listen: false).loadProjects();
    });
  }

  /// Handles taps on the bottom navigation bar.
  /// TODO (Navigation): Replace placeholder navigation when other pages are ready.
  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyLikesPage()),
      );
    } else if (index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This page is not available yet')),
      );
    }

    Provider.of<MyProjectsViewModel>(context, listen: false).navigateToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text(
          TextComponents.myProjectsTitle(),
          style: TextComponents.header18,
        ),
        centerTitle: true,
      ),
      body: Consumer<MyProjectsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorState(viewModel);
          }

          return _buildContent(viewModel);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () => _showCreateProjectDialog(context),
          backgroundColor: AppColors.primaryPurple,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  /// Displays an error message when loading projects fails.
  Widget _buildErrorState(MyProjectsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            TextComponents.projectsLoadError(),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TextComponents.dataLoadFallback,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.mediumGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.retryLoadProjects,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: Text(TextComponents.retry()),
          ),
        ],
      ),
    );
  }

  /// Builds the main content: either an empty state or a list of project cards.
  Widget _buildContent(MyProjectsViewModel viewModel) {
    if (viewModel.projects.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TextComponents.projectsCount(viewModel.projects.length),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: viewModel.projects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildProjectCard(viewModel, index),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a simple empty-state prompt when the user has no projects yet.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 72, color: AppColors.lightGrey),
            const SizedBox(height: 16),
            Text(TextComponents.noProjectsYet(), style: TextComponents.header16),
            const SizedBox(height: 8),
            Text(
              TextComponents.createFirstProject(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single project card with name, creator, and last updated date.
  /// TODO (Backend): Add project thumbnail or preview image once available.
  Widget _buildProjectCard(MyProjectsViewModel viewModel, int index) {
    final project = viewModel.projects[index];
    final projectName = project['name'] ?? "Untitled Project";
    final creator = project['creator'] ?? TextComponents.fallbackProjectCreator;
    final lastUpdated = project['lastUpdated'] as DateTime? ?? DateTime.now();

    return GestureDetector(
      onTap: () {
        // Navigate to camera page for this project
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CameraPage(
              projectId: project['id'],
              projectName: projectName,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(Icons.folder, color: AppColors.white),
          ),
          title: Text(projectName, style: TextComponents.header16),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TextComponents.createdBy(creator), style: TextComponents.body13Grey),
              Text(TextComponents.lastUpdate(_formatDate(lastUpdated)),
                  style: TextComponents.body13Grey),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.mediumGrey),
            onPressed: () => _showOptionsMenu(context, viewModel, project),
          ),
        ),
      ),
    );
  }

  /// Displays bottom sheet options for editing or deleting a project.
  void _showOptionsMenu(
      BuildContext context, MyProjectsViewModel viewModel, dynamic project) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(TextComponents.editProject()),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProjectDialog(context, viewModel, project);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: Text(
                  TextComponents.deleteProject(),
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, viewModel, project);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a dialog for creating a new project.
  /// TODO (Validation): Add duplicate name check before submitting.
  void _showCreateProjectDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TextComponents.createNewProject()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: TextComponents.enterProjectName(),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TextComponents.cancel()),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Provider.of<MyProjectsViewModel>(context, listen: false)
                      .createProject(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
              child: Text(TextComponents.create()),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for editing an existing project's name.
  void _showEditProjectDialog(
      BuildContext context, MyProjectsViewModel viewModel, dynamic project) {
    final TextEditingController controller =
    TextEditingController(text: project['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TextComponents.editProject()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: TextComponents.enterNewName(),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TextComponents.cancel()),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  viewModel.updateProject(project['id'], controller.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
              child: Text(TextComponents.save()),
            ),
          ],
        );
      },
    );
  }

  /// Confirms before permanently deleting a project.
  void _showDeleteConfirmationDialog(
      BuildContext context, MyProjectsViewModel viewModel, dynamic project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TextComponents.deleteProject()),
          content: Text(TextComponents.deleteConfirmation(project['name'])),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TextComponents.cancel()),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.deleteProject(project['id']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(TextComponents.deleteProject()),
            ),
          ],
        );
      },
    );
  }

  /// Formats a DateTime into a readable string for display.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
