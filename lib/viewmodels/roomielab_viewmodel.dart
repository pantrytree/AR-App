import 'dart:io';
import 'package:flutter/foundation.dart';

// RoomieLabViewModel
//
// Handles:
// - Saving and managing local design projects
// - Syncing captured images (from CameraPage)
// - Providing data to RoomieLabPage
//
// Future backend integration:
// - GET /projects -> fetch user projects
// - POST /projects -> upload new saved AR designs
// - DELETE /projects/{id} -> remove saved design
class RoomieLabViewModel extends ChangeNotifier {
  // List of locally saved design projects.
  // Each project contains:
  // {id, imagePath, furniture, timestamp, positionX, positionY, rotation}
  final List<Map<String, dynamic>> _savedProjects = [];
  List<Map<String, dynamic>> get savedProjects => List.unmodifiable(_savedProjects);

  // Tracks the last saved image (for smooth transitions / debugging)
  String? _lastSavedImagePath;
  String? get lastSavedImagePath => _lastSavedImagePath;

  // Loading and error states (for UI)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Simulates backend loading (for now, just fetches local memory list)
  Future<void> loadSavedProjects() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulated delay
    _setLoading(false);
  }

  // Adds a new saved project (e.g., after "Save" button pressed in CameraPage)
  void addProject(String imagePath, String furnitureType) {
    try {
      final newProject = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'imagePath': imagePath,
        'furniture': furnitureType,
        'timestamp': DateTime.now().toIso8601String(),
        'positionX': 0.5, // Default center position
        'positionY': 0.5, // Default center position
        'rotation': 0.0,  // Default rotation
      };

      _savedProjects.insert(0, newProject);
      _lastSavedImagePath = imagePath;
      notifyListeners();

      debugPrint(' Project saved: $furnitureType at $imagePath');
    } catch (e) {
      _errorMessage = 'Failed to save project: $e';
      notifyListeners();
    }
  }

  // NEW: Update project position and rotation (for editing)
  void updateProjectPosition(String projectId, double positionX, double positionY, double rotation) {
    try {
      final projectIndex = _savedProjects.indexWhere((project) => project['id'] == projectId);
      if (projectIndex != -1) {
        _savedProjects[projectIndex]['positionX'] = positionX;
        _savedProjects[projectIndex]['positionY'] = positionY;
        _savedProjects[projectIndex]['rotation'] = rotation;
        notifyListeners();
        debugPrint(' Project updated: $projectId - Position: ($positionX, $positionY), Rotation: $rotation');
      }
    } catch (e) {
      _errorMessage = 'Failed to update project: $e';
      notifyListeners();
    }
  }

  // NEW: Delete project by ID (for 3-dot menu)
  void deleteProjectById(String projectId) {
    try {
      final project = _savedProjects.firstWhere(
            (project) => project['id'] == projectId,
        orElse: () => {},
      );

      if (project.isNotEmpty) {
        deleteProject(project);
      }
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  // Deletes a saved project from memory (with optional local cleanup)
  void deleteProject(Map<String, dynamic> project) {
    try {
      _savedProjects.remove(project);

      // Optionally delete local image file
      final imagePath = project['imagePath'];
      if (imagePath != null && File(imagePath).existsSync()) {
        File(imagePath).deleteSync();
      }

      notifyListeners();
      debugPrint(' Project deleted: ${project['furniture']}');
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  // Clears all saved projects (for testing or reset)
  void clearAll() {
    _savedProjects.clear();
    notifyListeners();
  }

  // Retry logic placeholder (used if backend fails)
  void retryLoad() => loadSavedProjects();

  // Helper to toggle loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
