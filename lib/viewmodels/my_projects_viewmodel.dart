import 'package:flutter/foundation.dart';

class MyProjectsViewModel extends ChangeNotifier {
  final List<Project> _projects = [];
  List<Project> get projects => _projects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      //mock data
      _projects.addAll([
        Project(
          id: 1,
          title: 'Design 1',
          date: DateTime(2025, 8, 20),
          creator: 'Savanna',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
          thumbnailColor: 0xFFE0D7FF,
          creatorAvatarColor: 0xFF963CF1,
        ),
        Project(
          id: 2,
          title: 'Kitchen Plans',
          date: DateTime(2025, 8, 20),
          creator: 'Savanna',
          lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
          thumbnailColor: 0xFFE0D7FF,
          creatorAvatarColor: 0xFF963CF1,
        ),
        Project(
          id: 3,
          title: 'Design 2',
          date: DateTime(2025, 8, 20),
          creator: 'Savanna',
          lastUpdated: DateTime.now(),
          thumbnailColor: 0xFFE0D7FF,
          creatorAvatarColor: 0xFF963CF1,
        ),
      ]);

      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load projects. Please try again.';
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> createProject(String title) async {
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      date: DateTime.now(),
      creator: 'You',
      lastUpdated: DateTime.now(),
      thumbnailColor: _getRandomColor(),
      creatorAvatarColor: _getRandomColor(),
    );

    _projects.insert(0, newProject);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateProject(int projectId, String newTitle) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(
        title: newTitle,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> deleteProject(int projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implement real storage here
  }

  int _getRandomColor() {
    final colors = [0xFFE0D7FF, 0xFFD7E0FF, 0xFFE0FFD7];
    return colors[DateTime.now().millisecond % colors.length];
  }
}

class Project {
  final int id;
  final String title;
  final DateTime date;
  final String creator;
  final DateTime lastUpdated;
  final int thumbnailColor;
  final int creatorAvatarColor;

  Project({
    required this.id,
    required this.title,
    required this.date,
    required this.creator,
    required this.lastUpdated,
    required this.thumbnailColor,
    required this.creatorAvatarColor,
  });

  String get formattedDate {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedLastUpdate {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${difference.inDays ~/ 7}w ago';
  }

  Project copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? creator,
    DateTime? lastUpdated,
    int? thumbnailColor,
    int? creatorAvatarColor,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      creator: creator ?? this.creator,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      thumbnailColor: thumbnailColor ?? this.thumbnailColor,
      creatorAvatarColor: creatorAvatarColor ?? this.creatorAvatarColor,
    );
  }
}