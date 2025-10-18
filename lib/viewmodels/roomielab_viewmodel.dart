import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/design.dart';
import '../models/design_object.dart';
import '/models/project.dart';

class RoomieLabViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Properties
  List<Project> _projects = [];
  List<Design> _designs = []; // Add designs list
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<Project> get projects => _projects;
  List<Design> get designs => _designs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Create a new design for a project
  Future<String?> createDesign({
    required String projectId,
    required String name,
    List<DesignObject> objects = const [],
    String? imageUrl,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return null;
      }

      final designRef = _firestore.collection('designs').doc();
      final now = DateTime.now();

      final design = Design(
        id: designRef.id,
        userId: userId,
        projectId: projectId,
        name: name,
        objects: objects,
        imageUrl: imageUrl,
        createdAt: now,
        updatedAt: now,
        lastViewed: now,
      );

      await designRef.set(design.toFirestore());

      // Add to local designs list
      _designs.insert(0, design);
      notifyListeners();

      _successMessage = 'Design created successfully';
      notifyListeners();

      return designRef.id;
    } catch (e) {
      _errorMessage = 'Failed to create design: $e';
      notifyListeners();
      return null;
    }
  }

  /// Get project designs (furniture items in the project)
  Future<List<Design>> getProjectDesigns(String projectId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return [];
      }

      // Query designs collection for this project
      final designsSnapshot = await _firestore
          .collection('designs')
          .where('projectId', isEqualTo: projectId)
          .where('userId', isEqualTo: userId)
          .orderBy('lastViewed', descending: true)
          .get();

      final designs = designsSnapshot.docs.map((doc) {
        return Design.fromFirestore(doc);
      }).toList();

      // Update local designs list
      _designs = designs;
      notifyListeners();

      return designs;
    } catch (e) {
      _errorMessage = 'Failed to get project designs: $e';
      notifyListeners();
      return [];
    }
  }

  /// Update project design (furniture item)
  Future<bool> updateProjectDesign({
    required String projectId,
    required String designId,
    required String itemId,
    required Position position,
    required Rotation rotation,
    required Scale scale,
  }) async {
    try {
      final designRef = _firestore.collection('designs').doc(designId);

      // Get current design
      final designDoc = await designRef.get();
      if (!designDoc.exists) return false;

      final design = Design.fromFirestore(designDoc);

      // Find and update the specific DesignObject
      final updatedObjects = design.objects.map((obj) {
        if (obj.itemId == itemId) {
          return obj.copyWith(
            position: position,
            rotation: rotation,
            scale: scale,
          );
        }
        return obj;
      }).toList();

      // Update the design
      await designRef.update({
        'objects': updatedObjects.map((obj) => obj.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastViewed': FieldValue.serverTimestamp(),
      });

      // Update local state
      final designIndex = _designs.indexWhere((d) => d.id == designId);
      if (designIndex != -1) {
        _designs[designIndex] = _designs[designIndex].copyWith(
          objects: updatedObjects,
          updatedAt: DateTime.now(),
          lastViewed: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project design: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add a DesignObject to a design
  Future<bool> addDesignObject({
    required String designId,
    required DesignObject designObject,
  }) async {
    try {
      final designRef = _firestore.collection('designs').doc(designId);

      // Get current design
      final designDoc = await designRef.get();
      if (!designDoc.exists) return false;

      final design = Design.fromFirestore(designDoc);

      // Check if object already exists
      if (design.objects.any((obj) => obj.itemId == designObject.itemId)) {
        _errorMessage = 'Object already exists in design';
        notifyListeners();
        return false;
      }

      // Add new object
      final updatedObjects = [...design.objects, designObject];

      await designRef.update({
        'objects': updatedObjects.map((obj) => obj.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastViewed': FieldValue.serverTimestamp(),
      });

      // Update local state
      final designIndex = _designs.indexWhere((d) => d.id == designId);
      if (designIndex != -1) {
        _designs[designIndex] = _designs[designIndex].copyWith(
          objects: updatedObjects,
          updatedAt: DateTime.now(),
          lastViewed: DateTime.now(),
        );
        notifyListeners();
      }

      _successMessage = 'Object added to design';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add object to design: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove a DesignObject from a design
  Future<bool> removeDesignObject({
    required String designId,
    required String itemId,
  }) async {
    try {
      final designRef = _firestore.collection('designs').doc(designId);

      // Get current design
      final designDoc = await designRef.get();
      if (!designDoc.exists) return false;

      final design = Design.fromFirestore(designDoc);

      // Remove the object
      final updatedObjects = design.objects.where((obj) => obj.itemId != itemId).toList();

      await designRef.update({
        'objects': updatedObjects.map((obj) => obj.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastViewed': FieldValue.serverTimestamp(),
      });

      // Update local state
      final designIndex = _designs.indexWhere((d) => d.id == designId);
      if (designIndex != -1) {
        _designs[designIndex] = _designs[designIndex].copyWith(
          objects: updatedObjects,
          updatedAt: DateTime.now(),
          lastViewed: DateTime.now(),
        );
        notifyListeners();
      }

      _successMessage = 'Object removed from design';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove object from design: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update design metadata (name, image, etc.)
  Future<bool> updateDesignMetadata({
    required String designId,
    String? name,
    String? imageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        'lastViewed': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;

      await _firestore.collection('designs').doc(designId).update(updates);

      // Update local state
      final designIndex = _designs.indexWhere((d) => d.id == designId);
      if (designIndex != -1) {
        _designs[designIndex] = _designs[designIndex].copyWith(
          name: name ?? _designs[designIndex].name,
          imageUrl: imageUrl ?? _designs[designIndex].imageUrl,
          updatedAt: DateTime.now(),
          lastViewed: DateTime.now(),
        );
        notifyListeners();
      }

      _successMessage = 'Design updated successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update design: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get a specific design by ID
  Future<Design?> getDesign(String designId) async {
    try {
      final designDoc = await _firestore.collection('designs').doc(designId).get();

      if (designDoc.exists) {
        return Design.fromFirestore(designDoc);
      }

      return null;
    } catch (e) {
      _errorMessage = 'Failed to get design: $e';
      notifyListeners();
      return null;
    }
  }

  /// Delete a design
  Future<bool> deleteDesign(String designId) async {
    try {
      await _firestore.collection('designs').doc(designId).delete();

      // Remove from local state
      _designs.removeWhere((design) => design.id == designId);
      notifyListeners();

      _successMessage = 'Design deleted successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete design: $e';
      notifyListeners();
      return false;
    }
  }

  /// Create a new project
  Future<String?> createProject({
    required String name,
    required String roomType,
    required String imageUrl,
    List<String> items = const [],
    String description = '',
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return null;
      }

      final projectRef = _firestore.collection('projects').doc();
      final now = DateTime.now();

      final project = Project(
        id: projectRef.id,
        userId: userId,
        name: name,
        roomType: roomType,
        description: description,
        items: items,
        collaborators: [],
        createdAt: now,
        updatedAt: now,
        imageUrl: imageUrl,
        isPublic: false,
        isLiked: false,
        likeCount: 0,
        likedBy: [],
      );

      await projectRef.set(project.toFirestore());

      // Add to local projects list
      _projects.insert(0, project);
      notifyListeners();

      _successMessage = 'Project created successfully';
      notifyListeners();

      return projectRef.id;
    } catch (e) {
      _errorMessage = 'Failed to create project: $e';
      notifyListeners();
      return null;
    }
  }

  /// Get a specific project by ID
  Future<Project?> getProject(String projectId) async {
    try {
      final projectDoc = await _firestore.collection('projects').doc(projectId).get();

      if (projectDoc.exists) {
        final project = Project.fromFirestore(projectDoc);

        // Check if current user has liked this project
        final userId = _auth.currentUser?.uid;
        if (userId != null) {
          final isLiked = project.likedBy.contains(userId);
          return project.copyWith(isLiked: isLiked);
        }

        return project;
      }

      return null;
    } catch (e) {
      _errorMessage = 'Failed to get project: $e';
      notifyListeners();
      return null;
    }
  }

  /// Add furniture item to project
  Future<bool> addFurnitureToProject({
    required String projectId,
    required String furnitureId,
  }) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'items': FieldValue.arrayUnion([furnitureId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedItems = List<String>.from(_projects[projectIndex].items);
        updatedItems.add(furnitureId);
        _projects[projectIndex] = _projects[projectIndex].copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add furniture to project: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove furniture item from project
  Future<bool> removeFurnitureFromProject({
    required String projectId,
    required String furnitureId,
  }) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'items': FieldValue.arrayRemove([furnitureId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final updatedItems = List<String>.from(_projects[projectIndex].items);
        updatedItems.remove(furnitureId);
        _projects[projectIndex] = _projects[projectIndex].copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove furniture from project: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update project image
  Future<bool> updateProjectImage({
    required String projectId,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final projectIndex = _projects.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        _projects[projectIndex] = _projects[projectIndex].copyWith(
          imageUrl: imageUrl,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      _successMessage = 'Project image updated successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project image: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load projects for the current user
  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get projects where user is owner or collaborator
      final querySnapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      _projects = querySnapshot.docs.map((doc) {
        final project = Project.fromFirestore(doc);

        // Check if current user has liked this project
        final isLiked = project.likedBy.contains(userId);

        return project.copyWith(isLiked: isLiked);
      }).toList();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
      _projects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle like status for a project
  Future<bool> toggleProjectLike(String projectId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final projectRef = _firestore.collection('projects').doc(projectId);

      // Get current project data
      final projectDoc = await projectRef.get();
      if (!projectDoc.exists) return false;

      final project = Project.fromFirestore(projectDoc);
      final List<String> likedBy = List<String>.from(project.likedBy);
      final bool isCurrentlyLiked = likedBy.contains(userId);

      if (isCurrentlyLiked) {
        // Remove like
        likedBy.remove(userId);
      } else {
        // Add like
        likedBy.add(userId);
      }

      // Update project
      await projectRef.update({
        'likedBy': likedBy,
        'likeCount': likedBy.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(
          likedBy: likedBy,
          likeCount: likedBy.length,
          isLiked: !isCurrentlyLiked,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update like: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update project name
  Future<bool> updateProjectName(String projectId, String newName) async {
    try {
      if (newName.trim().isEmpty) return false;

      await _firestore.collection('projects').doc(projectId).update({
        'name': newName.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        _projects[index] = _projects[index].copyWith(name: newName.trim());
        notifyListeners();
      }

      _successMessage = 'Project name updated successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project name: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add collaborator to project
  Future<bool> addCollaborator(String projectId, String email) async {
    try {
      if (email.trim().isEmpty) return false;

      // First, find user by email to get their UID
      final users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .get();

      if (users.docs.isEmpty) {
        _errorMessage = 'User with email $email not found';
        notifyListeners();
        return false;
      }

      final collaboratorId = users.docs.first.id;
      final collaboratorData = users.docs.first.data();
      final collaboratorName = collaboratorData['displayName'] ?? collaboratorData['email'] ?? 'Unknown User';

      // Update project collaborators
      await _firestore.collection('projects').doc(projectId).update({
        'collaborators': FieldValue.arrayUnion([collaboratorId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final updatedCollaborators = List<String>.from(_projects[index].collaborators);
        updatedCollaborators.add(collaboratorId);
        _projects[index] = _projects[index].copyWith(collaborators: updatedCollaborators);
        notifyListeners();
      }

      _successMessage = 'Collaborator added successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add collaborator: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove collaborator from project
  Future<bool> removeCollaborator(String projectId, String userId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'collaborators': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final updatedCollaborators = List<String>.from(_projects[index].collaborators);
        updatedCollaborators.remove(userId);
        _projects[index] = _projects[index].copyWith(collaborators: updatedCollaborators);
        notifyListeners();
      }

      _successMessage = 'Collaborator removed successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove collaborator: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete project
  Future<bool> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();

      // Remove from local state
      _projects.removeWhere((project) => project.id == projectId);
      notifyListeners();

      _successMessage = 'Project deleted successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      notifyListeners();
      return false;
    }
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

  /// Get collaborator details (for displaying names instead of IDs)
  Future<Map<String, String>> getCollaboratorDetails(List<String> userIds) async {
    final Map<String, String> userDetails = {};

    try {
      for (final userId in userIds) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userDetails[userId] = userData['displayName'] ?? userData['email'] ?? 'Unknown User';
        }
      }
    } catch (e) {
      print('Error getting collaborator details: $e');
    }

    return userDetails;
  }
}