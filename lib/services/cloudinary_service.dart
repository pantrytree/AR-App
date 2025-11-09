import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static const String apiKey = '233457639813171';
  static const String apiSecret = 'ZILVNK-tNZvNoApvyCCP36S7MzM';
  static const String cloudName = 'dwvcvysdl';
  static const String uploadPreset = 'AR-App';

  // Build AR model URL from public ID
  String buildArModelUrl(String publicId) {
    print('=== BUILD AR MODEL URL ===');
    print('Input public ID: $publicId');

    // Check if publicId already has extension
    String finalPublicId;
    if (publicId.endsWith('.glb') || publicId.endsWith('.gltf')) {
      finalPublicId = publicId;
      print('Public ID already has extension');
    } else {
      // Add .glb extension
      finalPublicId = '$publicId.glb';
      print('Added .glb extension');
    }

    // Construct the raw URL
    final url = 'https://res.cloudinary.com/$cloudName/raw/upload/$finalPublicId';

    print('Final URL: $url');
    return url;
  }

  // Build AR model URL with version
  String buildArModelUrlWithVersion(String publicId, {int? version}) {
    final publicIdWithExtension = publicId.endsWith('.glb') ? publicId : '$publicId.glb';

    if (version != null) {
      final url = 'https://res.cloudinary.com/$cloudName/raw/upload/v$version/$publicIdWithExtension';
      print('Built versioned AR model URL: $url');
      return url;
    }

    return buildArModelUrl(publicId);
  }

  // Convert Cloudinary image URL to raw URL for 3D models
  String convertToRawUrl(String url) {
    if (!url.contains('cloudinary.com')) {
      return url; // Not a Cloudinary URL, return as-is
    }

    // Replace /image/upload/ with /raw/upload/
    if (url.contains('/image/upload/')) {
      return url.replaceAll('/image/upload/', '/raw/upload/');
    }

    // Replace /video/upload/ with /raw/upload/ (if needed)
    if (url.contains('/video/upload/')) {
      return url.replaceAll('/video/upload/', '/raw/upload/');
    }

    return url;
  }

  // Get AR-ready URL (handles both full URLs and public IDs)
  String getArModelUrl(String urlOrPublicId) {
    print('=== GET AR MODEL URL ===');
    print('Input: $urlOrPublicId');

    // Check if it's a full URL or just a public ID
    if (urlOrPublicId.startsWith('http://') || urlOrPublicId.startsWith('https://')) {
      // It's a full URL - convert to raw
      print('Input is a full URL');
      final cleanUrl = urlOrPublicId.split('?').first;
      final rawUrl = convertToRawUrl(cleanUrl);

      if (!rawUrl.toLowerCase().endsWith('.glb')) {
        print('WARNING: AR model URL does not end with .glb: $rawUrl');
      }

      print('Output: $rawUrl');
      return rawUrl;
    } else {
      // It's a public ID - build the URL
      print('Input is a public ID');
      final url = buildArModelUrl(urlOrPublicId);
      print('Output: $url');
      return url;
    }
  }

  // Extract public ID from full Cloudinary URL
  String? extractPublicIdFromUrl(String url) {
    if (!url.contains('cloudinary.com')) return null;

    try {
      final cleanUrl = url.split('?').first;
      final uri = Uri.parse(cleanUrl);
      final pathSegments = uri.pathSegments;

      // Find 'upload' in path
      final uploadIndex = pathSegments.indexWhere((segment) =>
      segment == 'upload' || segment == 'image' || segment == 'raw' || segment == 'video'
      );

      if (uploadIndex != -1) {
        // Everything after upload/v{version}/ is the public ID
        final startIndex = uploadIndex + 1;

        // Skip version if present (e.g., v1234567890)
        final firstSegment = pathSegments[startIndex];
        final actualStartIndex = firstSegment.startsWith('v') &&
            int.tryParse(firstSegment.substring(1)) != null
            ? startIndex + 1
            : startIndex;

        // Join remaining segments
        final publicIdParts = pathSegments.sublist(actualStartIndex);
        final publicId = publicIdParts.join('/');

        print('Extracted public ID: $publicId from URL: $url');
        return publicId;
      }
    } catch (e) {
      print('Error extracting public ID from URL: $e');
    }

    return null;
  }

  // Upload 3D model file (GLB) and return public ID
  Future<String> upload3DModel(File modelFile, String furnitureId) async {
    try {
      _validate3DModel(modelFile);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = '3D/models/furniture_3d_${furnitureId}_$timestamp';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/raw/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = uniquePublicId
        ..fields['timestamp'] = timestamp.toString()
        ..fields['resource_type'] = 'raw' // IMPORTANT: Specify raw resource type
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          modelFile.path,
        ));

      print('Uploading 3D model to Cloudinary...');
      print('Public ID: $uniquePublicId');

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final returnedPublicId = jsonResponse['public_id'];
        print('3D model uploaded successfully!');
        print('Public ID: $returnedPublicId');

        // Return just the public ID (not the full URL)
        return returnedPublicId;
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload 3D model: $e');
    }
  }

  // Validate 3D model file
  void _validate3DModel(File file) {
    if (!file.existsSync()) throw Exception('File does not exist');

    final extension = path.extension(file.path).toLowerCase();
    const allowed = ['.glb', '.gltf'];
    if (!allowed.contains(extension)) {
      throw Exception('Invalid 3D model type. Allowed: ${allowed.join(', ')}');
    }

    final fileSize = file.lengthSync();
    const maxSize = 50 * 1024 * 1024; // 50MB max for 3D models
    if (fileSize > maxSize) throw Exception('File too large (max 50MB)');
    if (fileSize == 0) throw Exception('File is empty');
  }

  Future<String> uploadProfileImageUnsigned(File imageFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = 'profile_${userId}_$timestamp';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'profile_images'
        ..fields['public_id'] = uniquePublicId
        ..fields['timestamp'] = timestamp.toString()
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ));

      print('Uploading to Cloudinary with public_id: $uniquePublicId');
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('Upload successful: $imageUrl');

        final cacheBustedUrl = '$imageUrl?t=$timestamp';
        return cacheBustedUrl;
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload: $e');
    }
  }

  Future<String> uploadScreenshot(Uint8List imageBytes, String fileName) async {
    print('=== UPLOADING SCREENSHOT TO CLOUDINARY ===');
    print('File name: $fileName');
    print('Image size: ${imageBytes.length} bytes');

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Convert bytes to base64
      final base64Image = base64Encode(imageBytes);
      final imageData = 'data:image/png;base64,$base64Image';

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      request.fields['file'] = imageData;
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'roomilab/screenshots';
      request.fields['public_id'] = fileName;

      print('Sending upload request...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        final secureUrl = jsonResponse['secure_url'] as String;

        print('✓ Upload successful!');
        print('URL: $secureUrl');

        return secureUrl;
      } else {
        print('✗ Upload failed');
        print('Response: $responseData');
        throw Exception('Failed to upload to Cloudinary: ${response.statusCode}');
      }
    } catch (e) {
      print('✗ Error uploading to Cloudinary: $e');
      rethrow;
    }
  }

  Future<String> uploadProjectImage(File imageFile, String projectId) async {
    try {
      _validateImage(imageFile);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = 'project_${projectId}_$timestamp';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'project_images'
        ..fields['public_id'] = uniquePublicId
        ..fields['timestamp'] = timestamp.toString()
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
        return '$imageUrl?t=$timestamp';
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload project image: $e');
    }
  }

  Future<String> uploadDesignImage(File imageFile, String designId) async {
    try {
      _validateImage(imageFile);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = 'design_${designId}_$timestamp';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'design_images'
        ..fields['public_id'] = uniquePublicId
        ..fields['timestamp'] = timestamp.toString()
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
        return '$imageUrl?t=$timestamp';
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload design image: $e');
    }
  }

  Future<String> uploadFurnitureImage(File imageFile, String furnitureId) async {
    try {
      _validateImage(imageFile);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = 'furniture_${furnitureId}_$timestamp';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'furniture_items'
        ..fields['public_id'] = uniquePublicId
        ..fields['timestamp'] = timestamp.toString()
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
        return '$imageUrl?t=$timestamp';
      } else {
        throw Exception('Upload failed: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload furniture image: $e');
    }
  }

  Future<String?> uploadImage({
    required String filePath,
    required String folder,
    String? publicId,
  }) async {
    try {
      final file = File(filePath);
      _validateImage(file);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniquePublicId = publicId ?? 'image_$timestamp';

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..fields['public_id'] = uniquePublicId
        ..fields['timestamp'] = timestamp.toString()
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
        return '$imageUrl?t=$timestamp';
      } else {
        print('Cloudinary upload failed: ${jsonResponse['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

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

  String getOptimizedImageUrl(String originalUrl, {int width = 300, int height = 300}) {
    if (!originalUrl.contains('cloudinary.com')) {
      return '$originalUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    final cleanUrl = originalUrl.split('?').first;

    final transformedUrl = cleanUrl.replaceFirst(
      '/upload/',
      '/upload/w_$width,h_$height,c_fill,q_auto,f_auto/',
    );

    return '$transformedUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  String getThumbnailUrl(String originalUrl, {int size = 150}) {
    if (!originalUrl.contains('cloudinary.com')) {
      return '$originalUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    }

    final cleanUrl = originalUrl.split('?').first;

    final thumbnailUrl = cleanUrl.replaceFirst(
      '/upload/',
      '/upload/w_$size,h_$size,c_fill,q_auto,f_auto/',
    );

    return '$thumbnailUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

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

    final sortedParams = params.keys.toList()..sort();
    final paramString = sortedParams
        .map((key) => '$key=${params[key]}')
        .join('&');

    final signatureString = '$paramString$apiSecret';
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

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

  String? extractPublicId(String imageUrl) {
    return extractPublicIdFromUrl(imageUrl);
  }

  Future<List<String>> uploadMultipleImages({
    required List<String> filePaths,
    required String folder,
    String? prefix,
  }) async {
    final uploadedUrls = <String>[];

    for (final filePath in filePaths) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniquePrefix = prefix != null ? '${prefix}_$timestamp' : 'image_$timestamp';

        final url = await uploadImage(
          filePath: filePath,
          folder: folder,
          publicId: uniquePrefix,
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

  String addCacheBusting(String url) {
    if (url.contains('?')) {
      return '$url&t=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<String> overrideProfileImage(File imageFile, String userId) async {
    try {
      final basePublicId = 'profile_$userId';
      final existingPublicId = await _findExistingPublicId(basePublicId);

      if (existingPublicId != null) {
        await deleteImage(existingPublicId);
        print('Deleted existing image: $existingPublicId');
      }

      return await uploadProfileImageUnsigned(imageFile, userId);
    } catch (e) {
      print('Error overriding profile image: $e');
      return await uploadProfileImageUnsigned(imageFile, userId);
    }
  }

  Future<String?> _findExistingPublicId(String basePublicId) async {
    return basePublicId;
  }
}
