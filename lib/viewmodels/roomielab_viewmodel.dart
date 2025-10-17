import 'dart:io';
import 'package:flutter/foundation.dart';
import '/services/project_service.dart';
import '/services/design_service.dart';
import '/services/furniture_service.dart';
import '/services/cloudinary_service.dart';
import '/models/project.dart';
import '/models/design.dart';
import '/models/design_object.dart';

class RoomieLabViewModel extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final DesignService _designService = DesignService();
  final FurnitureService _furnitureService = FurnitureService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Projects data
  List<Project> _projects = [];
  List<Project> get projects => List.unmodifiable(_projects);

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Track last saved for smooth transitions
  String? _lastSavedProjectId;
  String? get lastSavedProjectId => _lastSavedProjectId;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  /// Load all user's projects from Firestore
  Future<void> loadProjects() async {
    _setLoading(true);
    _clearMessages();

    try {
      print('Loading projects...');

      _projects = await _projectService.getProjects(useFirestore: true);

      print('Loaded ${_projects.length} projects');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load projects: ${e.toString()}';
      print('Error loading projects: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Stream projects for real-time updates
  Stream<List<Project>> streamProjects() {
    return _projectService.streamProjects();
  }

  Future<String?> createProject({
    required String name,
    required String roomType,
    required String imagePath,
    String? description,
    List<DesignObject>? designObjects,
  }) async {
    _setLoading(true);
    _clearMessages();
    _uploadProgress = 0.0;

    try {
      print('Creating new project: $name');

      // 1. Upload image to Cloudinary
      String? imageUrl;
      if (imagePath.isNotEmpty) {
        print('Uploading image to Cloudinary...');
        _uploadProgress = 0.3;
        notifyListeners();

        final imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          try {
            // Generate unique project ID for Cloudinary
            final projectId = DateTime.now().millisecondsSinceEpoch.toString();

            imageUrl = await _cloudinaryService.uploadProjectImage(
              imageFile,
              projectId,
            );

            print('Image uploaded: $imageUrl');
            _uploadProgress = 0.6;
            notifyListeners();
          } catch (e) {
            print('Image upload failed, using local path: $e');
            imageUrl = imagePath; // Fallback to local path
          }
        } else {
          print('Image file not found, skipping upload');
        }
      }

      // 2. Create the project
      _uploadProgress = 0.7;
      notifyListeners();

      final projectId = await _projectService.createProject(
        name: name,
        roomType: roomType,
        description: description,
        imageUrl: imageUrl,
        useFirestore: true,
      );

      print('Project created: $projectId');
      _uploadProgress = 0.85;
      notifyListeners();

      // 3. If there are design objects, create a design
      if (designObjects != null && designObjects.isNotEmpty) {
        await _designService.createDesign(
          name: '$name - Design',
          projectId: projectId,
          objects: designObjects,
          imageUrl: imageUrl,
          useFirestore: true,
        );
        print('Design saved with ${designObjects.length} objects');
      }

      // 4. Reload projects
      _uploadProgress = 0.95;
      notifyListeners();

      await loadProjects();

      _lastSavedProjectId = projectId;
      _successMessage = 'Project saved successfully!';
      _uploadProgress = 1.0;

      return projectId;
    } catch (e) {
      _errorMessage = 'Failed to create project: ${e.toString()}';
      print('Error creating project: $e');
      _uploadProgress = 0.0;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProject(
      String projectId, {
        String? name,
        String? roomType,
        String? description,
        String? imagePath,
      }) async {
    try {
      print('Updating project: $projectId');

      String? imageUrl;

      // Upload new image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          try {
            print('Uploading new image to Cloudinary...');
            imageUrl = await _cloudinaryService.uploadProjectImage(
              imageFile,
              projectId,
            );
            print('New image uploaded: $imageUrl');
          } catch (e) {
            print('Image upload failed: $e');
            // Continue without new image
          }
        }
      }

      await _projectService.updateProject(
        projectId,
        name: name,
        roomType: roomType,
        description: description,
        imageUrl: imageUrl,
        useFirestore: true,
      );

      // Reload projects to show updates
      await loadProjects();

      _successMessage = 'Project updated successfully!';
      print('Project updated');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project: ${e.toString()}';
      print('Error updating project: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update design objects within a project
  Future<bool> updateProjectDesign(
      String projectId,
      List<DesignObject> objects,
      ) async {
    try {
      print('Updating project design: $projectId');

      // Get designs for this project
      final designs = await _designService.getDesignsByProject(
        projectId,
        useFirestore: true,
      );

      if (designs.isEmpty) {
        // Create new design if none exists
        await _designService.createDesign(
          name: 'Design',
          projectId: projectId,
          objects: objects,
          useFirestore: true,
        );
      } else {
        // Update existing design
        await _designService.updateDesign(
          designs.first.id,
          objects: objects,
          useFirestore: true,
        );
      }

      _successMessage = 'Design updated successfully!';
      print('Design updated');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update design: ${e.toString()}';
      print('Error updating design: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a project by ID
  Future<bool> deleteProject(String projectId) async {
    _setLoading(true);
    _clearMessages();

    try {
      print('Deleting project: $projectId');

      // 1. Get project to extract image URL
      final project = await _projectService.getProject(projectId, useFirestore: true);

      // 2. Delete from Firestore
      await _projectService.deleteProject(projectId, useFirestore: true);

      // 3. Delete image from Cloudinary if exists
      if (project.imageUrl != null && project.imageUrl!.contains('cloudinary')) {
        try {
          print('Deleting image from Cloudinary...');
          final publicId = _extractPublicId(project.imageUrl!);
          if (publicId != null) {
            await _cloudinaryService.deleteImage(publicId);
            print('Cloudinary image deleted');
          }
        } catch (e) {
          print('Failed to delete Cloudinary image: $e');
          // Continue even if Cloudinary deletion fails
        }
      }

      // 4. Remove from local list
      _projects.removeWhere((p) => p.id == projectId);

      _successMessage = 'Project deleted successfully!';
      print('Project deleted');

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete project: ${e.toString()}';
      print('Error deleting project: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Duplicate an existing project
  Future<String?> duplicateProject(String projectId) async {
    _setLoading(true);
    _clearMessages();

    try {
      print('Duplicating project: $projectId');

      final newProjectId = await _projectService.duplicateProject(projectId);

      await loadProjects();

      _successMessage = 'Project duplicated successfully!';
      print('Project duplicated: $newProjectId');

      return newProjectId;
    } catch (e) {
      _errorMessage = 'Failed to duplicate project: ${e.toString()}';
      print('Error duplicating project: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get project by ID
  Future<Project?> getProject(String projectId) async {
    try {
      return await _projectService.getProject(projectId, useFirestore: true);
    } catch (e) {
      print('Error getting project: $e');
      return null;
    }
  }

  /// Get designs for a specific project
  Future<List<Design>> getProjectDesigns(String projectId) async {
    try {
      return await _designService.getDesignsByProject(
        projectId,
        useFirestore: true,
      );
    } catch (e) {
      print('Error getting project designs: $e');
      return [];
    }
  }

  /// Get project count
  Future<int> getProjectCount() async {
    try {
      return await _projectService.getProjectCount();
    } catch (e) {
      print('Error getting project count: $e');
      return 0;
    }
  }

  String? _extractPublicId(String imageUrl) {
    try {
      if (!imageUrl.contains('cloudinary.com')) return null;

      // Split URL and find the path after /upload/
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find 'upload' segment
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) {
        return null;
      }

      final relevantSegments = pathSegments.sublist(uploadIndex + 1);

      // Skip version if present
      final startIndex = relevantSegments.first.startsWith('v') ? 1 : 0;

      // Reconstruct path without extension
      final pathWithExtension = relevantSegments.sublist(startIndex).join('/');
      final publicId = pathWithExtension.substring(
        0,
        pathWithExtension.lastIndexOf('.'),
      );

      return publicId;
    } catch (e) {
      print('Failed to extract public_id: $e');
      return null;
    }
  }

  /// Retry loading projects
  void retryLoad() => loadProjects();

  /// Clear all messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}