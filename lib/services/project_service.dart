import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_service.dart';
import '/models/project.dart';
import '/models/furniture_item.dart';
import '/models/user.dart' as models;

class ProjectService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get User's Projects
  Future<List<Project>> getProjects({bool useFirestore = true}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (useFirestore) {
        final snapshot = await _firestore
            .collection('projects')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => Project.fromFirestore(doc))
            .toList();
      } else {
        final response = await _apiService.get('/projects', requiresAuth: true);
        return (response as List<dynamic>)
            .map((json) => Project.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  // Stream projects (Real-time)
  Stream<List<Project>> streamProjects() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Project.fromFirestore(doc))
          .toList();
    });
  }

  //  Get Single Project
  Future<Project> getProject(String projectId, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final doc = await _firestore.collection('projects').doc(projectId).get();

        if (!doc.exists) {
          throw Exception('Project not found');
        }

        return Project.fromFirestore(doc);
      } else {
        final response = await _apiService.get('/projects/$projectId', requiresAuth: true);
        return Project.fromJson(response as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to load project: $e');
    }
  }

  //  Stream single project
  Stream<Project?> streamProject(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Project.fromFirestore(doc);
    });
  }

  //  Create Project
  Future<String> createProject({
    required String name,
    required String roomType,
    String? description,
    String? imageUrl,
    bool useFirestore = true,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (useFirestore) {
        final now = DateTime.now();
        final project = Project(
          id: '',
          userId: userId,
          name: name,
          roomType: roomType,
          description: description ?? '',
          items: [],
          collaborators: [],
          createdAt: now,
          updatedAt: now,
          imageUrl: imageUrl,
        );

        final docRef = await _firestore
            .collection('projects')
            .add(project.toFirestore());

        return docRef.id;
      } else {
        final response = await _apiService.post(
          '/projects',
          body: {
            'name': name,
            'roomType': roomType,
            'description': description,
            'imageUrl': imageUrl,
          },
          requiresAuth: true,
        );
        return response['projectId'] as String;
      }
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  //  Update Project
  Future<void> updateProject(
      String projectId, {
        String? name,
        String? roomType,
        String? description,
        String? imageUrl,
        bool? isPublic,
        bool useFirestore = true,
      }) async {
    try {
      if (useFirestore) {
        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (name != null) updates['name'] = name;
        if (roomType != null) updates['roomType'] = roomType;
        if (description != null) updates['description'] = description;
        if (imageUrl != null) updates['imageUrl'] = imageUrl;
        if (isPublic != null) updates['isPublic'] = isPublic;

        await _firestore.collection('projects').doc(projectId).update(updates);
      } else {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (roomType != null) updates['roomType'] = roomType;
        if (description != null) updates['description'] = description;
        if (imageUrl != null) updates['imageUrl'] = imageUrl;
        if (isPublic != null) updates['isPublic'] = isPublic;

        await _apiService.put(
          '/projects/$projectId',
          body: updates,
          requiresAuth: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  //  Delete Project
  Future<void> deleteProject(String projectId, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        // Delete all designs associated with project
        final designsSnapshot = await _firestore
            .collection('designs')
            .where('projectId', isEqualTo: projectId)
            .get();

        for (var doc in designsSnapshot.docs) {
          await doc.reference.delete();
        }

        // Delete the project
        await _firestore.collection('projects').doc(projectId).delete();
      } else {
        await _apiService.delete('/projects/$projectId', requiresAuth: true);
      }
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  //  Add Item to Project
  Future<void> addItemToProject(String projectId, String itemId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'items': FieldValue.arrayUnion([itemId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add item to project: $e');
    }
  }

  // Remove Item from Project
  Future<void> removeItemFromProject(String projectId, String itemId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'items': FieldValue.arrayRemove([itemId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove item from project: $e');
    }
  }

  // Get Project Items (returns FurnitureItem models)
  Future<List<FurnitureItem>> getProjectItems(String projectId) async {
    try {
      final project = await getProject(projectId);

      if (project.items.isEmpty) return [];

      List<FurnitureItem> items = [];
      for (String itemId in project.items) {
        try {
          final itemDoc = await _firestore.collection('furnitureItem').doc(itemId).get();
          if (itemDoc.exists) {
            items.add(FurnitureItem.fromFirestore(itemDoc));
          }
        } catch (e) {
          print('Error fetching item $itemId: $e');
        }
      }

      return items;
    } catch (e) {
      throw Exception('Failed to load project items: $e');
    }
  }

  //  Share Project (Add Collaborator)
  Future<void> shareProject(String projectId, String userEmail) async {
    try {
      // Find user by email
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('User not found with email: $userEmail');
      }

      final collaboratorId = userSnapshot.docs.first.id;

      // Add to collaborators array
      await _firestore.collection('projects').doc(projectId).update({
        'collaborators': FieldValue.arrayUnion([collaboratorId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to share project: $e');
    }
  }

  // Remove Collaborator
  Future<void> removeCollaborator(String projectId, String userId) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'collaborators': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove collaborator: $e');
    }
  }

  //  Get Project Collaborators (returns User models)
  Future<List<models.User>> getProjectCollaborators(String projectId) async {
    try {
      final project = await getProject(projectId);

      if (project.collaborators.isEmpty) return [];

      List<models.User> collaborators = [];
      for (String userId in project.collaborators) {
        try {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            collaborators.add(models.User.fromFirestore(userDoc));
          }
        } catch (e) {
          print('Error fetching user $userId: $e');
        }
      }

      return collaborators;
    } catch (e) {
      throw Exception('Failed to load collaborators: $e');
    }
  }

  //  Get Shared Projects (projects where user is collaborator)
  Future<List<Project>> getSharedProjects() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('projects')
          .where('collaborators', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Project.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load shared projects: $e');
    }
  }

  //  Duplicate Project
  Future<String> duplicateProject(String projectId) async {
    try {
      final project = await getProject(projectId);

      return await createProject(
        name: '${project.name} (Copy)',
        roomType: project.roomType,
        description: project.description,
        imageUrl: project.imageUrl,
      );
    } catch (e) {
      throw Exception('Failed to duplicate project: $e');
    }
  }

  //  Get Project Count
  Future<int> getProjectCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  //  Check if user can access project
  Future<bool> canAccessProject(String projectId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final project = await getProject(projectId);

      return project.userId == userId ||
          project.collaborators.contains(userId);
    } catch (e) {
      return false;
    }
  }
}
