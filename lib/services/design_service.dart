import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '/services/api_service.dart';
import '/models/design.dart';
import '/models/design_object.dart';

enum DesignType {
  arLayout,    // 3D AR designs with DesignObjects
  imageDesign, // RoomieLab image-based designs
}

class DesignService {
  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Get User's Designs
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

  // Get Single Design
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

  //  Create Design (Save AR Layout)
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
  id: '',
  userId: userId,
  projectId: projectId,
  name: name,
  objects: objects,
  imageUrl: imageUrl,
  createdAt: now,
  updatedAt: now,
    lastViewed: now,
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

  //  Update Design
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

  //  Delete Design
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

  //  Get Designs by Project
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

  //  Add object to design
  Future<void> addObjectToDesign(String designId, DesignObject object) async {
  try {
  final design = await getDesign(designId);
  final updatedObjects = [...design.objects, object];

  await updateDesign(designId, objects: updatedObjects);
  } catch (e) {
  throw Exception('Failed to add object to design: $e');
  }
  }

  //  Remove object from design
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

  //  Update object in design
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

  //  Duplicate design
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

  // Get design count
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

  //  Create Image Design (RoomieLab)
  Future<String> createImageDesign({
  required String name,
  required String projectId,
  required File imageFile,
  String? description,
  Map<String, dynamic>? metadata,
  }) async {
  try {
  final imageUrl = await _uploadToCloudinary(imageFile);

  // Use existing createDesign method but with empty objects for image designs
  return await createDesign(
  name: name,
  projectId: projectId,
  objects: [], // Empty objects for image designs
  imageUrl: imageUrl,
  );
  } catch (e) {
  throw Exception('Failed to create image design: $e');
  }
  }

  //  Cloudinary upload helper
  Future<String> _uploadToCloudinary(File imageFile) async {
  try {
  final response = await _apiService.post(
  '/upload/design-image',
  body: {
  'image': base64Encode(await imageFile.readAsBytes()),
  'folder': 'roomielab-designs',
  },
  requiresAuth: true,
  );

  return response['imageUrl'] as String;
  } catch (e) {
  throw Exception('Failed to upload image to Cloudinary: $e');
  }
  }

  //  Get designs by type (using imageUrl as indicator)
  Future<List<Design>> getImageDesigns({String? projectId}) async {
  final allDesigns = await getDesigns();

  // Filter designs that have imageUrl but no objects (RoomieLab designs)
  return allDesigns.where((design) {
  final hasImage = design.imageUrl != null && design.imageUrl!.isNotEmpty;
  final noObjects = design.objects.isEmpty;
  final projectMatch = projectId == null || design.projectId == projectId;

  return hasImage && noObjects && projectMatch;
  }).toList();
  }

  Future<List<Design>> getARDesigns({String? projectId}) async {
  final allDesigns = await getDesigns();

  // Filter designs that have objects (AR designs)
  return allDesigns.where((design) {
  final hasObjects = design.objects.isNotEmpty;
  final projectMatch = projectId == null || design.projectId == projectId;

  return hasObjects && projectMatch;
  }).toList();
  }

  //  Enhanced Get Designs with filtering
  Future<List<Design>> getDesignsWithFilter({
  String? projectId,
  bool? isImageDesign,
  }) async {
  final designs = await getDesigns();

  return designs.where((design) {
  final projectMatch = projectId == null || design.projectId == projectId;

  if (isImageDesign == null) return projectMatch;

  if (isImageDesign) {
  // Image design: has imageUrl but no objects
  return projectMatch &&
  design.imageUrl != null &&
  design.imageUrl!.isNotEmpty &&
  design.objects.isEmpty;
  } else {
  // AR design: has objects
  return projectMatch && design.objects.isNotEmpty;
  }
  }).toList();
  }

  //  Enhanced Streams with filtering
  Stream<List<Design>> streamDesignsWithFilter({
  String? projectId,
  bool? isImageDesign,
  }) {
  return streamDesigns().map((designs) {
  return designs.where((design) {
  final projectMatch = projectId == null || design.projectId == projectId;

  if (isImageDesign == null) return projectMatch;

  if (isImageDesign) {
  // Image design: has imageUrl but no objects
  return projectMatch &&
  design.imageUrl != null &&
  design.imageUrl!.isNotEmpty &&
  design.objects.isEmpty;
  } else {
  // AR design: has objects
  return projectMatch && design.objects.isNotEmpty;
  }
  }).toList();
  });
  }

  //  Update image design (RoomieLab specific)
  Future<void> updateImageDesign(
  String designId, {
  String? name,
  String? description,
  }) async {
  try {
  // Use existing updateDesign method
  await updateDesign(
  designId,
  name: name,
  );
  } catch (e) {
  throw Exception('Failed to update image design: $e');
  }
  }

  //  Get design statistics
  Future<Map<String, int>> getDesignStats() async {
  final designs = await getDesigns();

  final imageDesigns = designs.where((d) =>
  d.imageUrl != null && d.imageUrl!.isNotEmpty && d.objects.isEmpty
  ).length;

  final arDesigns = designs.where((d) => d.objects.isNotEmpty).length;

  return {
  'total': designs.length,
  'arDesigns': arDesigns,
  'imageDesigns': imageDesigns,
  };
  }

  //  Check if design is RoomieLab image design
  bool isImageDesign(Design design) {
  return design.imageUrl != null &&
  design.imageUrl!.isNotEmpty &&
  design.objects.isEmpty;
  }

  //  Check if design is AR design
  bool isARDesign(Design design) {
  return design.objects.isNotEmpty;
  }
}
