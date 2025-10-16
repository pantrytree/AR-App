import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roomielab_model.dart';

class RoomieLabService {
  static const String _designsKey = 'roomielab_designs';

  Future<String> saveImage(File imageFile) async {
    try {
      // Get the application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = '${appDocDir.path}/roomielab_images';

      // Create the directory if it doesn't exist
      final Directory imagesDir = Directory(imagesDirPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String newImagePath = '$imagesDirPath/image_$timestamp.jpg';

      // Copy the image to the new location
      await imageFile.copy(newImagePath);

      print('Image saved to: $newImagePath');
      return newImagePath;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  Future<void> saveDesign(RoomieLabDesign design) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing designs
      final List<RoomieLabDesign> existingDesigns = await getDesigns();

      // Add the new design
      existingDesigns.add(design);

      // Convert to JSON and save
      final List<Map<String, dynamic>> designsJson =
      existingDesigns.map((design) => design.toJson()).toList();

      await prefs.setString(_designsKey, json.encode(designsJson));

      print('Design saved successfully! Total designs: ${existingDesigns.length}');
    } catch (e) {
      print('Error saving design: $e');
      rethrow;
    }
  }

  Future<List<RoomieLabDesign>> getDesigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? designsJson = prefs.getString(_designsKey);

      if (designsJson == null) {
        return [];
      }

      final List<dynamic> designsList = json.decode(designsJson);
      return designsList.map((designJson) =>
          RoomieLabDesign.fromJson(Map<String, dynamic>.from(designJson))
      ).toList();
    } catch (e) {
      print('Error loading designs: $e');
      return [];
    }
  }

  Future<void> deleteDesign(String designId) async {
    try {
      final List<RoomieLabDesign> designs = await getDesigns();
      designs.removeWhere((design) => design.id == designId);

      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> designsJson =
      designs.map((design) => design.toJson()).toList();

      await prefs.setString(_designsKey, json.encode(designsJson));
    } catch (e) {
      print('Error deleting design: $e');
      rethrow;
    }
  }
}