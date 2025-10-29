import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:Roomantics/services/design_service.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/design.dart';
import '../models/design_object.dart';
import '../models/furniture_item.dart';
import '../services/furniture_service.dart';
import '../services/cloudinary_service.dart';
import '../services/project_service.dart';

class CameraViewModel extends ChangeNotifier {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  ARNode? _placedNode;
  bool _isObjectPlaced = false;

  double _currentScale = 0.5;
  double _currentRotationAngle = 0.0;

  final FurnitureService _furnitureService = FurnitureService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final DesignService _designService = DesignService();
  final ProjectService _projectService = ProjectService();

  List<DesignObject> _currentDesignObjects = [];
  List<DesignObject> get currentDesignObjects => _currentDesignObjects;
  List<FurnitureItem> _availableFurnitureItems = [];
  FurnitureItem? _selectedFurnitureItem;
  bool _isLoading = false;
  String? _error;

  Uint8List? _lastScreenshot;
  Uint8List? get lastScreenshot => _lastScreenshot;

  double get currentScale => _currentScale;

  String? _capturedImagePath;
  String? get capturedImagePath => _capturedImagePath;

  bool get isObjectPlaced => _isObjectPlaced;
  List<FurnitureItem> get availableFurnitureItems => _availableFurnitureItems;
  FurnitureItem? get selectedFurnitureItem => _selectedFurnitureItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // AR Session Manager getter for ProjectEditPage
  ARSessionManager? get arSessionManager => _arSessionManager;

  Future<void> loadFurnitureItems() async {
    print('LOADING FURNITURE ITEMS');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allItems = await _furnitureService.getFurnitureItems(useFirestore: true);
      print('Total items from Firestore: ${allItems.length}');

      for (var item in allItems) {
        print('Item: ${item.name}, AR URL: ${item.arModelUrl}');
      }

      _availableFurnitureItems = allItems
          .where((item) {
        final hasUrl = item.arModelUrl != null && item.arModelUrl!.isNotEmpty;
        if (!hasUrl) {
          print('Filtered out ${item.name} - no AR URL');
        }
        return hasUrl;
      }).toList();

      print('Items with AR models: ${_availableFurnitureItems.length}');

      if (_availableFurnitureItems.isNotEmpty) {
        _selectedFurnitureItem = _availableFurnitureItems.first;
        print('Selected: ${_selectedFurnitureItem!.name}');
        print('Selected AR URL: ${_selectedFurnitureItem!.arModelUrl}');
      } else {
        print('WARNING: No furniture items with AR models found!');
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load furniture items: $e';
      print('ERROR loading furniture: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFurnitureItem(FurnitureItem furnitureItem) {
    _selectedFurnitureItem = furnitureItem;
    print('FURNITURE SELECTED');
    print('Name: ${furnitureItem.name}');
    print('AR URL: ${furnitureItem.arModelUrl}');
    notifyListeners();
  }

  void onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager, ARAnchorManager anchorManager, ARLocationManager locationManager) {
    print('AR VIEW CREATED');
    _arSessionManager = sessionManager;
    _arObjectManager = objectManager;
    _arAnchorManager = anchorManager;

    _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      showAnimatedGuide: false,
    );

    _arObjectManager!.onInitialize();
    print('AR managers initialized');
    notifyListeners();
  }

  Future<void> placeOrRemoveFurniture() async {
    print('PLACE OR REMOVE FURNITURE CALLED');

    try {
      if (_isObjectPlaced) {
        print('Object already placed, removing...');
        await resetFurniture();
        return;
      }

      if (_arObjectManager == null) {
        print('ERROR: AR Object Manager is null!');
        _error = 'AR not initialized. Please restart the app.';
        notifyListeners();
        return;
      }

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      String? furnitureItemId;

      if (_selectedFurnitureItem != null) {
        print(' SELECTED FURNITURE ITEM ');
        furnitureItemId = _selectedFurnitureItem!.id;

        if (_selectedFurnitureItem!.arModelUrl != null &&
            _selectedFurnitureItem!.arModelUrl!.isNotEmpty) {
          modelUrl = _cloudinaryService.getArModelUrl(_selectedFurnitureItem!.arModelUrl!);
        }
      }

      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: Vector3(_currentScale, _currentScale, _currentScale),
        position: Vector3(0, -0.5, -2),
      );

      final didAdd = await _arObjectManager!.addNode(node).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('addNode() timed out');
          return false;
        },
      );

      if (didAdd == true) {
        _placedNode = node;
        _isObjectPlaced = true;
        _currentRotationAngle = 0.0;

        // Create and track design object
        final designObject = DesignObject(
          itemId: furnitureItemId ?? 'default_item',
          position: Position(
            x: node.position.x,
            y: node.position.y,
            z: node.position.z,
          ),
          rotation: Rotation(
            x: 0,
            y: _currentRotationAngle,
            z: 0,
          ),
          scale: Scale(
            x: node.scale.x,
            y: node.scale.y,
            z: node.scale.z,
          ),
        );

        _currentDesignObjects.add(designObject);
        _error = null;
        print('FURNITURE PLACED SUCCESSFULLY!');
        print('Design object created: ${designObject.toMap()}');
      } else {
        _error = 'Unable to place furniture';
      }
    } catch (e, stackTrace) {
      _error = 'Error: $e';
      print('EXCEPTION PLACING FURNITURE: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> scaleFurniture(double scaleDelta) async {
    try {
      if (_placedNode == null || _arObjectManager == null) {
        print('Cannot scale: no object placed or AR not initialized');
        return;
      }

      print('=== SCALING FURNITURE ===');

      await _arObjectManager!.removeNode(_placedNode!);
      print('Old node removed');

      // Update scale with limits (min: 0.1, max: 2.0)
      _currentScale = (_currentScale + scaleDelta).clamp(0.1, 2.0);
      print('New scale: $_currentScale');

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      if (_selectedFurnitureItem != null &&
          _selectedFurnitureItem!.arModelUrl != null &&
          _selectedFurnitureItem!.arModelUrl!.isNotEmpty) {
        modelUrl = _cloudinaryService.getArModelUrl(_selectedFurnitureItem!.arModelUrl!);
      }

      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: Vector3(_currentScale, _currentScale, _currentScale), // UPDATED: Use current scale
        position: _placedNode!.position,
        rotation: Vector4(0, 1, 0, _currentRotationAngle),
      );

      bool didAdd = await _arObjectManager!.addNode(node) ?? false;
      if (didAdd) {
        _placedNode = node;
        print('✓ Furniture scaled successfully to $_currentScale');
      } else {
        print('✗ Failed to add scaled node');
        _isObjectPlaced = false;
        _placedNode = null;
        _error = 'Failed to scale furniture';
      }

      notifyListeners();
    } catch (e) {
      print('Error scaling furniture: $e');
      _error = 'Failed to scale furniture: $e';
      _isObjectPlaced = false;
      _placedNode = null;
      notifyListeners();
    }
  }

  Future<void> moveFurniture(double deltaX, double deltaY, double deltaZ) async {
    try {
      if (_placedNode == null || _arObjectManager == null) return;

      final currentPos = _placedNode!.position;
      final newPos = Vector3(
        currentPos.x + deltaX,
        currentPos.y + deltaY,
        currentPos.z + deltaZ,
      );

      await _arObjectManager!.removeNode(_placedNode!);

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      String? furnitureItemId;

      if (_selectedFurnitureItem != null &&
          _selectedFurnitureItem!.arModelUrl != null &&
          _selectedFurnitureItem!.arModelUrl!.isNotEmpty) {
        modelUrl = _cloudinaryService.getArModelUrl(_selectedFurnitureItem!.arModelUrl!);
        furnitureItemId = _selectedFurnitureItem!.id;
      }

      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: Vector3(_currentScale, _currentScale, _currentScale),
        position: newPos,
        rotation: Vector4(0, 1, 0, _currentRotationAngle),
      );

      bool didAdd = await _arObjectManager!.addNode(node) ?? false;
      if (didAdd) {
        _placedNode = node;

        // Update design object position
        if (_currentDesignObjects.isNotEmpty) {
          final updatedObject = _currentDesignObjects.last.copyWith(
            position: Position(
              x: newPos.x,
              y: newPos.y,
              z: newPos.z,
            ),
          );
          _currentDesignObjects[_currentDesignObjects.length - 1] = updatedObject;
        }

        print('Furniture moved and design object updated');
      } else {
        _isObjectPlaced = false;
        _placedNode = null;
      }
      notifyListeners();
    } catch (e) {
      print('Error moving furniture: $e');
    }
  }

  Future<void> rotateFurniture(double angleRadians) async {
    try {
      if (_placedNode == null || _arObjectManager == null) return;

      await _arObjectManager!.removeNode(_placedNode!);
      _currentRotationAngle += angleRadians;

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      String? furnitureItemId;

      if (_selectedFurnitureItem != null &&
          _selectedFurnitureItem!.arModelUrl != null &&
          _selectedFurnitureItem!.arModelUrl!.isNotEmpty) {
        modelUrl = _cloudinaryService.getArModelUrl(_selectedFurnitureItem!.arModelUrl!);
        furnitureItemId = _selectedFurnitureItem!.id;
      }

      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: Vector3(_currentScale, _currentScale, _currentScale),
        position: _placedNode!.position,
        rotation: Vector4(0, 1, 0, _currentRotationAngle),
      );

      bool didAdd = await _arObjectManager!.addNode(node) ?? false;
      if (didAdd) {
        _placedNode = node;

        // Update design object rotation
        if (_currentDesignObjects.isNotEmpty) {
          final updatedObject = _currentDesignObjects.last.copyWith(
            rotation: Rotation(
              x: 0,
              y: _currentRotationAngle,
              z: 0,
            ),
          );
          _currentDesignObjects[_currentDesignObjects.length - 1] = updatedObject;
        }

        print('Furniture rotated and design object updated');
      } else {
        _isObjectPlaced = false;
        _placedNode = null;
      }
      notifyListeners();
    } catch (e) {
      print('Error rotating furniture: $e');
    }
  }

  Future<void> captureScreenshot() async {
    if (_arSessionManager == null) {
      print('AR Session Manager is null');
      return;
    }

    print(' CAPTURING SCREENSHOT');
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Get screenshot from AR session
      final imageProvider = await _arSessionManager!.snapshot();

      if (imageProvider == null) {
        _error = 'Failed to capture screenshot';
        print('Screenshot is null');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Screenshot captured, type: ${imageProvider.runtimeType}');

      // Convert ImageProvider to ui.Image
      final imageStream = imageProvider.resolve(ImageConfiguration());
      final completer = Completer<ui.Image>();

      late ImageStreamListener listener;
      listener = ImageStreamListener(
            (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete(info.image);
          }
          imageStream.removeListener(listener);
        },
        onError: (Object exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception, stackTrace ?? StackTrace.current);
          }
          imageStream.removeListener(listener);
        },
      );

      imageStream.addListener(listener);

      // Wait for image to load
      final ui.Image image = await completer.future;
      print('Image loaded: ${image.width}x${image.height}');

      // Convert ui.Image to Uint8List
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        _error = 'Failed to convert screenshot to bytes';
        print('Failed to convert screenshot to bytes');
        _isLoading = false;
        notifyListeners();
        return;
      }

      _lastScreenshot = byteData.buffer.asUint8List();

      // Also save to file path for file-based operations
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/ar_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(_lastScreenshot!);
      _capturedImagePath = imagePath;

      print('Screenshot captured successfully (${_lastScreenshot!.length} bytes)');
      print('Saved to: $imagePath');

    } catch (e, stackTrace) {
      _error = 'Error capturing screenshot: $e';
      print('Exception capturing screenshot: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    try {
      print('Starting Cloudinary upload for AR design...');

      // Generate unique design ID for the upload
      final designId = 'ar_design_${DateTime.now().millisecondsSinceEpoch}';

      // Use the design image upload method from CloudinaryService
      final imageUrl = await _cloudinaryService.uploadDesignImage(imageFile, designId);

      print('Cloudinary upload successful: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Cloudinary upload failed: $e');
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  Future<bool> saveDesign(String designName) async {
    if (_capturedImagePath == null) {
      _error = 'No screenshot captured';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Cloudinary
      final imageFile = File(_capturedImagePath!);
      final imageUrl = await _uploadImageToCloudinary(imageFile);

      // Create a project first
      final projectId = await _projectService.createProject(
        name: '$designName Project',
        roomType: _determineRoomType(),
        description: 'AR design created with RoomieLab',
        imageUrl: imageUrl,
        useFirestore: true,
      );

      // Create design with objects using your DesignService
      final designId = await _designService.createDesign(
        name: designName,
        projectId: projectId,
        objects: _currentDesignObjects,
        imageUrl: imageUrl,
        useFirestore: true,
      );

      print('Design saved successfully!');
      print('Project ID: $projectId');
      print('Design ID: $designId');
      print('Objects saved: ${_currentDesignObjects.length}');

      // Reset after successful save
      resetCapture();
      _currentDesignObjects.clear();

      return true;
    } catch (e) {
      _error = 'Failed to save design: ${e.toString()}';
      print('Save design error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save to device gallery
  Future<bool> saveToGallery() async {
    if (_lastScreenshot == null) {
      _error = 'No screenshot available';
      notifyListeners();
      return false;
    }

    print(' SAVING SCREENSHOT TO GALLERY ');

    try {
      // Request storage permission
      final PermissionStatus status = await Permission.photos.request();

      if (!status.isGranted && !status.isLimited) {
        print('✗ Permission denied: $status');
        _error = 'Storage permission denied';
        notifyListeners();
        return false;
      }

      // Save image using photo_manager
      final String result = (await PhotoManager.editor.saveImage(
        _lastScreenshot!,
        title: 'roomilab_${DateTime.now().millisecondsSinceEpoch}.png', filename: '',
      )) as String;

      print('PhotoManager save result: $result');

      if (result.isNotEmpty) {
        print('Screenshot saved to gallery with path: $result');
        return true;
      } else {
        print('Failed to save screenshot - empty result');
        _error = 'Failed to save to gallery';
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      print('Error saving to gallery: $e');
      print('Stack trace: $stackTrace');
      _error = 'Error saving to gallery: $e';
      notifyListeners();
      return false;
    }
  }

  String _determineRoomType() {
    if (_selectedFurnitureItem != null) {
      return _selectedFurnitureItem!.roomType;
    }
    return 'Living Room';
  }

  void resetCapture() {
    _capturedImagePath = null;
    _lastScreenshot = null;
    notifyListeners();
  }

  Future<void> resetFurniture() async {
    try {
      if (_placedNode != null && _arObjectManager != null) {
        print('Removing node: ${_placedNode!.name}');
        final removed = await _arObjectManager!.removeNode(_placedNode!);
        print('Node removal result: $removed');
        _placedNode = null;
      } else {
        print('No node to remove or AR not initialized');
      }

      _isObjectPlaced = false;
      _currentRotationAngle = 0.0;
      _currentDesignObjects.clear();
      _currentScale = 0.5;
      _error = null;
      notifyListeners();
    } catch (e) {
      print('Error resetting furniture: $e');
    }
  }

  void addFurnitureToDesign(FurnitureItem furnitureItem, ARNode node) {
    final designObject = DesignObject(
      itemId: furnitureItem.id,
      position: Position(
        x: node.position.x,
        y: node.position.y,
        z: node.position.z,
      ),
      rotation: Rotation(
        x: 0,
        y: _currentRotationAngle,
        z: 0,
      ),
      scale: Scale(
        x: node.scale.x,
        y: node.scale.y,
        z: node.scale.z,
      ),
    );

    _currentDesignObjects.add(designObject);
    notifyListeners();
  }

  // Get current design state
  Map<String, dynamic> getCurrentDesignState() {
    return {
      'objects': _currentDesignObjects.map((obj) => obj.toMap()).toList(),
      'isObjectPlaced': _isObjectPlaced,
      'selectedFurniture': _selectedFurnitureItem?.toFirestore(),
    };
  }

  Future<void> loadDesignForEditing(String designId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final design = await _designService.getDesign(designId, useFirestore: true);

      // Set current design objects for AR placement
      _currentDesignObjects = design.objects;

      print('Loaded design for editing: ${design.name}');
      print('Objects to place: ${design.objects.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load design: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update design objects
  Future<bool> updateDesignObjects(String designId) async {
    try {
      await _designService.updateDesign(
        designId,
        objects: _currentDesignObjects,
        useFirestore: true,
      );
      print('Design objects updated successfully');
      return true;
    } catch (e) {
      _error = 'Failed to update design: $e';
      print('Update design error: $e');
      return false;
    }
  }

  // Get designs for a project
  Future<List<Design>> getProjectDesigns(String projectId) async {
    try {
      return await _designService.getDesignsByProject(projectId, useFirestore: true);
    } catch (e) {
      print('Error getting project designs: $e');
      return [];
    }
  }

  void disposeAR() {
    _arSessionManager?.dispose();
  }

  @override
  void dispose() {
    disposeAR();
    super.dispose();
  }
}
