import 'package:flutter/foundation.dart';


/// Backend API Endpoints Needed
/// - GET /projects           -> Load all projects for the current user
/// - POST /projects          -> Create a new project
/// - PUT /projects/{id}      -> Update an existing project (e.g., name)
/// - DELETE /projects/{id}   -> Delete a project
///
/// When backend integration starts:
/// - Replace all placeholder data with actual API calls.
/// - Update methods to use real Project models instead of maps.
class MyProjectsViewModel extends ChangeNotifier {
  /// Internal list of all user projects.
  /// Each project is represented as a map with keys:
  /// {id, name, creator, lastUpdated}.
  /// Backend team: Replace this with a typed Project model when connected
  /// and populate data using GET /projects.
  final List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> get projects => List.unmodifiable(_projects);

  /// Tracks loading state.
  /// Used to show loading indicators in the UI while waiting for data.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Stores an error message (if any) that occurred during data operations.
  /// When not null, the UI should show an error state.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Initializes the ViewModel when the page loads for the first time.
  /// This is a good place to load any user data or saved projects.
  /// Backend team: You may also initialize user session data here.
  Future<void> initialize() async {
    // Placeholder logic for now.
    // Backend team: Fetch initial project list and user info here.
  }

  /// Loads all projects (simulated locally for now).
  /// Backend team:
  /// - Replace with GET /projects endpoint.
  /// - Update [_projects] with real API data.
  /// - Handle failed responses and network errors by setting [_errorMessage].
  Future<void> loadProjects() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Simulate a short network delay
      await Future.delayed(const Duration(seconds: 1));

      // Placeholder project data
      _projects
        ..clear()
        ..addAll([
          {
            'id': '1',
            'name': 'Project 1',
            'creator': 'User A',
            'lastUpdated': DateTime.now(),
          },
          {
            'id': '2',
            'name': 'Project 2',
            'creator': 'User B',
            'lastUpdated': DateTime.now(),
          },
        ]);

      // Backend team: Replace with actual data mapping from API response
    } catch (e) {
      _errorMessage = 'Failed to load projects.';
      debugPrint('Error loading projects: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new project (currently in memory only).
  /// UI triggers this when the user taps "Create Project".
  /// Backend team:
  /// - Replace with POST /projects.
  /// - Return created project data and update the list.
  /// - Handle validation errors (e.g., duplicate names).
  Future<void> createProject(String name) async {
    final newProject = {
      'id': DateTime.now().toString(), // Temporary unique ID
      'name': name,
      'creator': 'Current User', // Placeholder until backend user data is available
      'lastUpdated': DateTime.now(),
    };

    _projects.insert(0, newProject);
    notifyListeners();

    // Backend team: Send POST request to create project.
    // If creation fails, remove the project from the list and show an error.
  }

  /// Updates an existing project’s name (placeholder logic).
  /// Triggered when the user edits the project name from the options menu.
  /// Backend team:
  /// - Replace with PUT /projects/{id}.
  /// - Update project name and timestamp based on backend response.
  /// - Handle failure by reverting the name change.
  Future<void> updateProject(String projectId, String newName) async {
    final index = _projects.indexWhere((p) => p['id'] == projectId);
    if (index != -1) {
      _projects[index] = {
        ..._projects[index],
        'name': newName,
        'lastUpdated': DateTime.now(),
      };
      notifyListeners();

      // Backend team: Update project in the database.
      // Rollback changes if the update request fails.
    }
  }

  /// Deletes a project (in-memory placeholder).
  /// Triggered when the user confirms deletion from the bottom sheet.
  /// Backend team:
  /// - Replace with DELETE /projects/{id}.
  /// - On success, remove the project from state.
  /// - If deletion fails, restore the project and show an error message.
  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p['id'] == projectId);
    notifyListeners();

    // Backend team: Remove from database here.
    // Handle network failures gracefully.
  }

  /// Retries project loading after an error.
  /// Called from the UI when the user presses "Retry".
  /// Backend team: Ensure retry logic re-attempts the API request safely
  /// and respects previous load state.
  void retryLoadProjects() {
    loadProjects();
  }

  /// Handles bottom navigation actions.
  /// Used to communicate between this ViewModel and navigation layer.
  /// TODO (Backend/UI team):
  /// - Implement actual navigation or routing here later.
  void navigateToPage(int index) {
    debugPrint('Navigation index changed: $index');
  }

  /// Internal helper to manage loading state and update the UI.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}