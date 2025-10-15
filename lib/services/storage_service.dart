import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

enum StorageFolder {
  profileImages,
  designImages,
  projectImages,
  furnitureImages,
  arModels,
  temp;

  String get path {
    switch (this) {
      case StorageFolder.profileImages:
        return 'profile_images';
      case StorageFolder.designImages:
        return 'design_images';
      case StorageFolder.projectImages:
        return 'project_images';
      case StorageFolder.furnitureImages:
        return 'furniture_images';
      case StorageFolder.arModels:
        return 'ar_models';
      case StorageFolder.temp:
        return 'temp';
    }
  }
}

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Max file sizes (in bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxModelSize = 50 * 1024 * 1024; // 50 MB

  // Allowed extensions
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  static const List<String> allowedModelExtensions = ['.glb', '.gltf', '.obj', '.fbx', '.usdz'];

  // 1. Upload Profile Image

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Validate file
      _validateImage(imageFile);

      // Delete existing profile image first
      await deleteProfileImage();

      // Generate filename
      final fileName = 'profile_$userId${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('${StorageFolder.profileImages.path}/$fileName');

      // Upload with progress monitoring
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: _getContentType(path.extension(imageFile.path)),
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'profile_image',
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📤 Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      print('Profile image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // 2. Upload Design Image (AR Screenshot)

  Future<String> uploadDesignImage(File imageFile, String designId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      _validateImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'design_${designId}_$timestamp${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('${StorageFolder.designImages.path}/$userId/$fileName');

      await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: _getContentType(path.extension(imageFile.path)),
          customMetadata: {
            'userId': userId,
            'designId': designId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'design_image',
          },
        ),
      );

      final downloadUrl = await ref.getDownloadURL();

      print('Design image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload design image: $e');
      throw Exception('Failed to upload design image: $e');
    }
  }

  // 3. Upload Project Image

  Future<String> uploadProjectImage(File imageFile, String projectId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      _validateImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'project_${projectId}_$timestamp${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('${StorageFolder.projectImages.path}/$userId/$fileName');

      await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: _getContentType(path.extension(imageFile.path)),
          customMetadata: {
            'userId': userId,
            'projectId': projectId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'project_image',
          },
        ),
      );

      final downloadUrl = await ref.getDownloadURL();

      print('Project image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload project image: $e');
      throw Exception('Failed to upload project image: $e');
    }
  }

  // 4. Upload Furniture Image (Admin/Catalog)

  Future<String> uploadFurnitureImage(File imageFile, String furnitureId) async {
    try {
      _validateImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'furniture_${furnitureId}_$timestamp${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('${StorageFolder.furnitureImages.path}/$fileName');

      await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: _getContentType(path.extension(imageFile.path)),
          customMetadata: {
            'furnitureId': furnitureId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'furniture_image',
          },
        ),
      );

      final downloadUrl = await ref.getDownloadURL();

      print('Furniture image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload furniture image: $e');
      throw Exception('Failed to upload furniture image: $e');
    }
  }

  // 5. Upload Multiple Furniture Images (Batch)

  Future<List<String>> uploadFurnitureImages(
      List<File> imageFiles,
      String furnitureId,
      ) async {
    try {
      List<String> downloadUrls = [];

      for (var imageFile in imageFiles) {
        final url = await uploadFurnitureImage(imageFile, furnitureId);
        downloadUrls.add(url);
      }

      print('Uploaded ${downloadUrls.length} furniture images');
      return downloadUrls;
    } catch (e) {
      print('Failed to upload furniture images: $e');
      throw Exception('Failed to upload furniture images: $e');
    }
  }

  // 6. Upload AR Model (3D model file)

  Future<String> uploadARModel(File modelFile, String furnitureId) async {
    try {
      // Validate model file
      _validateModel(modelFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ar_model_${furnitureId}_$timestamp${path.extension(modelFile.path)}';
      final ref = _storage.ref().child('${StorageFolder.arModels.path}/$fileName');

      final uploadTask = ref.putFile(
        modelFile,
        SettableMetadata(
          contentType: _getContentType(path.extension(modelFile.path)),
          customMetadata: {
            'furnitureId': furnitureId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'type': 'ar_model',
          },
        ),
      );

      // Monitor upload progress (3D models can be large)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Model upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      print('AR model uploaded successfully');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload AR model: $e');
      throw Exception('Failed to upload AR model: $e');
    }
  }

  // 7. Delete File by URL

  Future<void> deleteFile(String fileUrl) async {
    try {
      if (fileUrl.isEmpty) return;

      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();

      print('File deleted successfully');
    } catch (e) {
      print('Failed to delete file (non-critical): $e');
      // Don't throw - deletion failures are non-critical
    }
  }

  // 8. Delete Profile Image

  Future<void> deleteProfileImage() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // List and delete all profile images for this user
      final ref = _storage.ref().child(StorageFolder.profileImages.path);
      final result = await ref.listAll();

      for (var item in result.items) {
        if (item.name.contains(userId)) {
          await item.delete();
          print('Deleted profile image: ${item.name}');
        }
      }
    } catch (e) {
      print('Failed to delete profile image: $e');
    }
  }

  // 9. Delete Design Image

  Future<void> deleteDesignImage(String imageUrl) async {
    try {
      await deleteFile(imageUrl);
    } catch (e) {
      print('Failed to delete design image: $e');
    }
  }

  // 10. Delete All Design Images for a Design

  Future<void> deleteAllDesignImages(String designId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final ref = _storage.ref().child('${StorageFolder.designImages.path}/$userId');
      final result = await ref.listAll();

      for (var item in result.items) {
        if (item.name.contains(designId)) {
          await item.delete();
          print('Deleted design image: ${item.name}');
        }
      }
    } catch (e) {
      print('Failed to delete design images: $e');
    }
  }

  // ========================================================================
  // 11. Delete Project Image
  // ========================================================================

  Future<void> deleteProjectImage(String imageUrl) async {
    try {
      await deleteFile(imageUrl);
    } catch (e) {
      print('Failed to delete project image: $e');
    }
  }

  // 12. Delete All Project Images for a Project

  Future<void> deleteAllProjectImages(String projectId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final ref = _storage.ref().child('${StorageFolder.projectImages.path}/$userId');
      final result = await ref.listAll();

      for (var item in result.items) {
        if (item.name.contains(projectId)) {
          await item.delete();
          print('Deleted project image: ${item.name}');
        }
      }
    } catch (e) {
      print('Failed to delete project images: $e');
    }
  }

  // 13. Delete All User Data (on account deletion)

  Future<void> deleteAllUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      print('Starting deletion of all user storage data...');

      // Delete profile images
      await deleteProfileImage();

      // Delete design images folder
      final designRef = _storage.ref().child('${StorageFolder.designImages.path}/$userId');
      await _deleteFolder(designRef);

      // Delete project images folder
      final projectRef = _storage.ref().child('${StorageFolder.projectImages.path}/$userId');
      await _deleteFolder(projectRef);

      print('All user storage data deleted');
    } catch (e) {
      print('Failed to delete all user data: $e');
    }
  }

  // 14. Get File Metadata

  Future<FullMetadata?> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('Failed to get file metadata: $e');
      return null;
    }
  }

  // 15. Get File Size


  Future<int> getFileSize(String fileUrl) async {
    try {
      final metadata = await getFileMetadata(fileUrl);
      return metadata?.size ?? 0;
    } catch (e) {
      print('Failed to get file size: $e');
      return 0;
    }
  }

  // 16. Check if File Exists

  Future<bool> fileExists(String fileUrl) async {
    try {
      final metadata = await getFileMetadata(fileUrl);
      return metadata != null;
    } catch (e) {
      return false;
    }
  }

  // 17. Get User's Total Storage Usage

  Future<int> getUserStorageUsage() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      int totalSize = 0;

      // Profile images
      final profileRef = _storage.ref().child(StorageFolder.profileImages.path);
      final profileFiles = await profileRef.listAll();
      for (var item in profileFiles.items) {
        if (item.name.contains(userId)) {
          final metadata = await item.getMetadata();
          totalSize += metadata.size ?? 0;
        }
      }

      // Design images
      final designRef = _storage.ref().child('${StorageFolder.designImages.path}/$userId');
      totalSize += await _getFolderSize(designRef);

      // Project images
      final projectRef = _storage.ref().child('${StorageFolder.projectImages.path}/$userId');
      totalSize += await _getFolderSize(projectRef);

      print('Total storage usage: ${formatStorageSize(totalSize)}');
      return totalSize;
    } catch (e) {
      print('Failed to calculate storage usage: $e');
      return 0;
    }
  }

  Future<List<Reference>> listUserFiles(StorageFolder folder) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final ref = _storage.ref().child('${folder.path}/$userId');
      final result = await ref.listAll();

      return result.items;
    } catch (e) {
      print('Failed to list files: $e');
      return [];
    }
  }

  Future<List<String>> getUserFileUrls(StorageFolder folder) async {
    try {
      final files = await listUserFiles(folder);

      List<String> urls = [];
      for (var file in files) {
        final url = await file.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Failed to get file URLs: $e');
      return [];
    }
  }

  // Validate image file
  void _validateImage(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      throw Exception('File does not exist');
    }

    // Check file extension
    final extension = path.extension(file.path).toLowerCase();
    if (!allowedImageExtensions.contains(extension)) {
      throw Exception('Invalid file type. Allowed: ${allowedImageExtensions.join(", ")}');
    }

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > maxImageSize) {
      throw Exception('File too large. Maximum size: ${formatStorageSize(maxImageSize)}');
    }

    if (fileSize == 0) {
      throw Exception('File is empty');
    }
  }

  // Validate 3D model file
  void _validateModel(File file) {
    // Check if file exists
    if (!file.existsSync()) {
      throw Exception('File does not exist');
    }

    // Check file extension
    final extension = path.extension(file.path).toLowerCase();
    if (!allowedModelExtensions.contains(extension)) {
      throw Exception('Invalid model type. Allowed: ${allowedModelExtensions.join(", ")}');
    }

    // Check file size
    final fileSize = file.lengthSync();
    if (fileSize > maxModelSize) {
      throw Exception('Model too large. Maximum size: ${formatStorageSize(maxModelSize)}');
    }

    if (fileSize == 0) {
      throw Exception('File is empty');
    }
  }

  // Delete entire folder recursively
  Future<void> _deleteFolder(Reference folderRef) async {
    try {
      final result = await folderRef.listAll();

      // Delete all files
      for (var item in result.items) {
        await item.delete();
        print('✅ Deleted: ${item.name}');
      }

      // Recursively delete subfolders
      for (var prefix in result.prefixes) {
        await _deleteFolder(prefix);
      }
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  // Get total size of folder
  Future<int> _getFolderSize(Reference folderRef) async {
    try {
      final result = await folderRef.listAll();
      int size = 0;

      for (var item in result.items) {
        final metadata = await item.getMetadata();
        size += metadata.size ?? 0;
      }

      // Recursively get size of subfolders
      for (var prefix in result.prefixes) {
        size += await _getFolderSize(prefix);
      }

      return size;
    } catch (e) {
      print('Error calculating folder size: $e');
      return 0;
    }
  }

  // Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.glb':
        return 'model/gltf-binary';
      case '.gltf':
        return 'model/gltf+json';
      case '.obj':
        return 'model/obj';
      case '.fbx':
        return 'application/octet-stream';
      case '.usdz':
        return 'model/vnd.usdz+zip';
      default:
        return 'application/octet-stream';
    }
  }

  /// Format bytes to human-readable size
  String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Generate unique filename with timestamp
  String generateUniqueFilename(String originalFilename) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalFilename);
    final nameWithoutExt = path.basenameWithoutExtension(originalFilename);
    return '${nameWithoutExt}_$timestamp$extension';
  }

  /// Get file extension from path
  String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Check if file is an image
  bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return allowedImageExtensions.contains(extension);
  }

  /// Check if file is a 3D model
  bool isModelFile(String filePath) {
    final extension = getFileExtension(filePath);
    return allowedModelExtensions.contains(extension);
  }

  /// Get storage quota percentage (assuming 1GB free tier)
  Future<double> getStorageQuotaPercentage({int quotaInBytes = 1024 * 1024 * 1024}) async {
    final usage = await getUserStorageUsage();
    return (usage / quotaInBytes) * 100;
  }

  /// Check if user is near storage limit
  Future<bool> isNearStorageLimit({
    int quotaInBytes = 1024 * 1024 * 1024,
    double threshold = 90.0,
  }) async {
    final percentage = await getStorageQuotaPercentage(quotaInBytes: quotaInBytes);
    return percentage >= threshold;
  }
}