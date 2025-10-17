import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static const String apiKey = '233457639813171';
  static const String apiSecret = 'ZILVNK-tNZvNoApvyCCP36S7MzM';
  static const String cloudName = 'dwvcvysdl';
  static const String uploadPreset = 'AR-App';

  /// Upload profile image using unsigned upload preset
  Future<String> uploadProfileImageUnsigned(File imageFile, String userId) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'profile_images'
        ..fields['public_id'] = 'profile_$userId'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

      print('Uploading to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('Upload successful: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload: $e');
    }
  }

  /// Upload project/design image
  Future<String> uploadProjectImage(File imageFile, String projectId) async {
    try {
      _validateImage(imageFile);

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'project_images'
        ..fields['public_id'] = 'project_$projectId'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

      print('Uploading project image to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('Project image uploaded: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload project image: $e');
    }
  }

  /// Upload design/furniture image
  Future<String> uploadDesignImage(File imageFile, String designId) async {
    try {
      _validateImage(imageFile);

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'design_images'
        ..fields['public_id'] = 'design_$designId'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

      print('Uploading design image to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('Design image uploaded: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload design image: $e');
    }
  }

  /// Upload furniture item image
  Future<String> uploadFurnitureImage(File imageFile, String furnitureId) async {
    try {
      _validateImage(imageFile);

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'furniture_items'
        ..fields['public_id'] = 'furniture_$furnitureId'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

      print('Uploading furniture image to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('Furniture image uploaded: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload furniture image: $e');
    }
  }

  /// Generic image upload method
  Future<String?> uploadImage({
    required String filePath,
    required String folder,
    String? publicId,
  }) async {
    try {
      final file = File(filePath);
      _validateImage(file);

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..fields['public_id'] = publicId ?? 'image_${DateTime.now().millisecondsSinceEpoch}'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
        ));

      print('Uploading image to Cloudinary folder: $folder');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        print('Cloudinary upload failed: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Delete image from Cloudinary
  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature for deletion
      final signature = _generateSignature(
        timestamp: timestamp,
        publicId: publicId,
      );

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      final response = await http.post(
        url,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        print('Image deleted successfully');
      } else {
        print('Delete failed: ${response.body}');
      }
    } catch (e) {
      print('Delete error: $e');
    }
  }

  /// Generate optimized image URL for display
  String getOptimizedImageUrl(String originalUrl, {int width = 300, int height = 300}) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    // Cloudinary URL transformation
    final transformedUrl = originalUrl.replaceFirst(
      '/upload/',
      '/upload/w_$width,h_$height,c_fill,q_auto,f_auto/',
    );

    return transformedUrl;
  }

  /// Generate thumbnail URL
  String getThumbnailUrl(String originalUrl, {int size = 150}) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/w_$size,h_$size,c_fill,q_auto,f_auto/',
    );
  }

  /// Generate signature for authenticated requests
  String _generateSignature({
    required int timestamp,
    String? publicId,
    String? folder,
  }) {
    final params = <String, String>{
      'timestamp': timestamp.toString(),
      if (publicId != null) 'public_id': publicId,
      if (folder != null) 'folder': folder,
    };

    // Sort parameters alphabetically
    final sortedParams = params.keys.toList()..sort();
    final paramString = sortedParams
        .map((key) => '$key=${params[key]}')
        .join('&');

    // Create signature
    final signatureString = '$paramString$apiSecret';
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  /// Validate image file
  void _validateImage(File file) {
    if (!file.existsSync()) throw Exception('File does not exist');

    final extension = path.extension(file.path).toLowerCase();
    const allowed = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    if (!allowed.contains(extension)) {
      throw Exception('Invalid file type. Allowed: ${allowed.join(', ')}');
    }

    final fileSize = file.lengthSync();
    const maxSize = 10 * 1024 * 1024;
    if (fileSize > maxSize) throw Exception('File too large (max 10MB)');
    if (fileSize == 0) throw Exception('File is empty');
  }

  /// Extract public ID from Cloudinary URL
  String? extractPublicId(String imageUrl) {
    if (!imageUrl.contains('cloudinary.com')) return null;

    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex + 1 < pathSegments.length) {
        final publicIdWithExtension = pathSegments.last;
        final publicId = publicIdWithExtension.split('.').first;
        return publicId;
      }
    } catch (e) {
      print('Error extracting public ID: $e');
    }

    return null;
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<String> filePaths,
    required String folder,
    String? prefix,
  }) async {
    final uploadedUrls = <String>[];

    for (final filePath in filePaths) {
      try {
        final url = await uploadImage(
          filePath: filePath,
          folder: folder,
          publicId: prefix != null ? '${prefix}_${DateTime.now().millisecondsSinceEpoch}' : null,
        );

        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        print('Failed to upload image $filePath: $e');
      }
    }

    return uploadedUrls;
  }
}