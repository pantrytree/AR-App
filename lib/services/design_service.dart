import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_service.dart';
import '/models/design.dart';
import '/models/design_object.dart';

class DesignService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get User's Designs (Returns Design models)
  // Endpoint: GET /api/designs

  Future<List<Design>> getDesigns({bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final userId = _auth.currentUser?.uid;
        if (userId == null) throw Exception('User not authenticated');

        final snapshot = await _firestore
            .collection('designs')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => Design.fromFirestore(doc))
            .toList();
      } else {
        final response = await _apiService.get('/designs', requiresAuth: true);
        return (response as List<dynamic>)
            .map((json) => Design.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load designs: $e');
    }
  }

  // Stream designs (Real-time updates)
  Stream<List<Design>> streamDesigns() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('designs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Design.fromFirestore(doc))
          .toList();
    });
  }

  // 2. Get Single Design (Returns Design model)
  // Endpoint: GET /api/designs/:designId
  Future<Design> getDesign(String designId, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final doc = await _firestore.collection('designs').doc(designId).get();

        if (!doc.exists) {
          throw Exception('Design not found');
        }

        return Design.fromFirestore(doc);
      } else {
        final response = await _apiService.get('/designs/$designId', requiresAuth: true);
        return Design.fromJson(response as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to load design: $e');
    }
  }

  // Stream single design (Real-time updates)
  Stream<Design?> streamDesign(String designId) {
    return _firestore
        .collection('designs')
        .doc(designId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Design.fromFirestore(doc);
    });
  }

  // 3. Create Design (Save AR Layout) - Uses Design model
  // Endpoint: POST /api/designs
  Future<String> createDesign({
    required String name,
    required String projectId,
    required List<DesignObject> objects,
    String? imageUrl,
    bool useFirestore = true,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      if (useFirestore) {
        final now = DateTime.now();
        final design = Design(
          id: '', // Firestore will generate
          userId: userId,
          projectId: projectId,
          name: name,
          objects: objects,
          imageUrl: imageUrl,
          createdAt: now,
          updatedAt: now,
        );

        final docRef = await _firestore
            .collection('designs')
            .add(design.toFirestore());

        return docRef.id;
      } else {
        final response = await _apiService.post(
          '/designs',
          body: {
            'name': name,
            'projectId': projectId,
            'objects': objects.map((obj) => obj.toJson()).toList(),
            'imageUrl': imageUrl,
          },
          requiresAuth: true,
        );
        return response['designId'] as String;
      }
    } catch (e) {
      throw Exception('Failed to create design: $e');
    }
  }

  // 4. Update Design
  // Endpoint: PUT /api/designs/:designId

  Future<void> updateDesign(
      String designId, {
        String? name,
        List<DesignObject>? objects,
        String? imageUrl,
        bool useFirestore = true,
      }) async {
    try {
      if (useFirestore) {
        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (name != null) updates['name'] = name;
        if (objects != null) {
          updates['objects'] = objects.map((obj) => obj.toMap()).toList();
        }
        if (imageUrl != null) updates['imageUrl'] = imageUrl;

        await _firestore.collection('designs').doc(designId).update(updates);
      } else {
        final updates = <String, dynamic>{};
        if (name != null) updates['name'] = name;
        if (objects != null) {
          updates['objects'] = objects.map((obj) => obj.toJson()).toList();
        }
        if (imageUrl != null) updates['imageUrl'] = imageUrl;

        await _apiService.put(
          '/designs/$designId',
          body: updates,
          requiresAuth: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to update design: $e');
    }
  }

  // 5. Delete Design
  // Endpoint: DELETE /api/designs/:designId

  Future<void> deleteDesign(String designId, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        await _firestore.collection('designs').doc(designId).delete();
      } else {
        await _apiService.delete('/designs/$designId', requiresAuth: true);
      }
    } catch (e) {
      throw Exception('Failed to delete design: $e');
    }
  }

  // 6. Get Designs by Project
  // Endpoint: GET /api/designs/project/:projectId

  Future<List<Design>> getDesignsByProject(String projectId, {bool useFirestore = true}) async {
    try {
      if (useFirestore) {
        final snapshot = await _firestore
            .collection('designs')
            .where('projectId', isEqualTo: projectId)
            .orderBy('createdAt', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => Design.fromFirestore(doc))
            .toList();
      } else {
        final response = await _apiService.get(
          '/designs/project/$projectId',
          requiresAuth: true,
        );
        return (response as List<dynamic>)
            .map((json) => Design.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to load project designs: $e');
    }
  }

  // Stream designs by project (Real-time updates)

  Stream<List<Design>> streamDesignsByProject(String projectId) {
    return _firestore
        .collection('designs')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Design.fromFirestore(doc))
          .toList();
    });
  }

  // 7. Add object to design
  Future<void> addObjectToDesign(String designId, DesignObject object) async {
    try {
      final design = await getDesign(designId);
      final updatedObjects = [...design.objects, object];

      await updateDesign(designId, objects: updatedObjects);
    } catch (e) {
      throw Exception('Failed to add object to design: $e');
    }
  }

  // 8. Remove object from design

  Future<void> removeObjectFromDesign(String designId, String itemId) async {
    try {
      final design = await getDesign(designId);
      final updatedObjects = design.objects
          .where((obj) => obj.itemId != itemId)
          .toList();

      await updateDesign(designId, objects: updatedObjects);
    } catch (e) {
      throw Exception('Failed to remove object from design: $e');
    }
  }

  // 9. Update object in design

  Future<void> updateObjectInDesign(String designId, DesignObject updatedObject) async {
    try {
      final design = await getDesign(designId);
      final updatedObjects = design.objects.map((obj) {
        return obj.itemId == updatedObject.itemId ? updatedObject : obj;
      }).toList();

      await updateDesign(designId, objects: updatedObjects);
    } catch (e) {
      throw Exception('Failed to update object in design: $e');
    }
  }

  // 10. Duplicate design

  Future<String> duplicateDesign(String designId) async {
    try {
      final design = await getDesign(designId);

      return await createDesign(
        name: '${design.name} (Copy)',
        projectId: design.projectId,
        objects: design.objects,
        imageUrl: design.imageUrl,
      );
    } catch (e) {
      throw Exception('Failed to duplicate design: $e');
    }
  }

  // 11. Get design count

  Future<int> getDesignCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('designs')
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}