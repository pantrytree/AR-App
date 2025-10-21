import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart'; // Import for Vector3
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart'; // Import for ARSessionManager, ARObjectManager, NodeType
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/services/furniture_service.dart';
import 'package:roomantics/models/design_object.dart' as design_models;
import 'package:roomantics/models/furniture_item.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/furniture_item.dart';
import '../utils/colors.dart';
import 'home_viewmodel.dart';

class CameraViewModel extends ChangeNotifier {
  final HomeViewModel _homeViewModel = HomeViewModel.instance;
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String? _error;
  List<CameraDescription>? _cameras;
  
  
  
  // AR Scene / Plugin controller
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARNode? _currentNode; // Currently selected AR object in the scene
  Vector4? _currentRotation = Vector4(0, 0, 0, 0);

  // AR state
  bool _isObjectPlaced = false;
  String _selectedObject = 'Sofa';
  List<FurnitureItem> _availableFurnitureItems = [];
  FurnitureItem? _selectedFurnitureItem;

  // Capture state
  String? _capturedImagePath;
  List<design_models.DesignObject> _placedObjects = [];

  // Getters
  bool get isCameraReady => _isCameraReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isObjectPlaced => _isObjectPlaced;
  String get selectedObject => _selectedObject;
  List<FurnitureItem> get availableFurnitureItems => _availableFurnitureItems;
  FurnitureItem? get selectedFurnitureItem => _selectedFurnitureItem;
  CameraController? get controller => _controller;
  String? get capturedImagePath => _capturedImagePath;
  bool get hasCapturedImage => _capturedImagePath != null;
  List<design_models.DesignObject> get placedObjects => _placedObjects;

  // ADDED: availableObjects getter for backward compatibility
  List<String> get availableObjects => _availableFurnitureItems.map((item) => item.name).toList();

  final FurnitureService _furnitureService = FurnitureService();



  // ===========================================================
  // INITIALIZATION
  // ===========================================================
  Future<void> initializeCamera() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Starting camera initialization...');

      // 1️⃣ Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _error = 'Camera permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2️⃣ Initialize available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _error = 'No cameras available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('📸 Cameras found: ${_cameras!.length}');

      // 3️⃣ Initialize CameraController
      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isCameraReady = true;
      print('✅ Camera initialized successfully');

      // 4️⃣ Load furniture items after camera is ready
      await loadFurnitureItems();

    } catch (e) {
      print('❌ Camera initialization failed: $e');
      _error = 'Failed to initialize camera: $e';
      _isCameraReady = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFurnitureItems() async {
    try {
      final items = await _furnitureService.getFurnitureItems();
      _availableFurnitureItems = items; // ✅ assign to backing list
      // If no selected object yet, pick first
      if (_selectedFurnitureItem == null && items.isNotEmpty) {
        _selectedFurnitureItem = items.first;
        _selectedObject = _selectedFurnitureItem!.name;
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load furniture items: $e');
    }
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ) {
    try {
      print('🔄 AR View Created - Initializing...');

      _arSessionManager = arSessionManager;
      _arObjectManager = arObjectManager;

      // Initialize AR session
      _arSessionManager!.onInitialize(
        showFeaturePoints: true,
        showPlanes: true,
        customPlaneTexturePath: "assets/triangle.png",
        showWorldOrigin: true,
        handleTaps: true,
      );

      // Initialize object manager
      _arObjectManager!.onInitialize();

      print('✅ AR Session initialized successfully');

    } catch (e) {
      print('❌ AR initialization failed: $e');
      _error = 'AR initialization failed: $e';
    }

    notifyListeners();
  }

  // ===========================================================
  // AR OBJECT MANAGEMENT
  // ===========================================================
  void selectObject(String objectName) {
    _selectedObject = objectName;
    _selectedFurnitureItem = _availableFurnitureItems.firstWhere(
          (item) => item.name == objectName,
      orElse: () => _availableFurnitureItems.first,
    );
    notifyListeners();
  }

  void selectFurnitureItem(FurnitureItem item) {
    _selectedFurnitureItem = item;
    _selectedObject = item.name;
    notifyListeners();
  }

  void placeObject(Offset position, double scale, double rotation) {
    if (_selectedFurnitureItem == null) return;

    // Create a design object with the placement data
    final designObject = design_models.DesignObject(
      itemId: _selectedFurnitureItem!.id,
      position: design_models.Position(
        x: position.dx,
        y: position.dy,
        z: 0.0,
      ),
      rotation: design_models.Rotation(
        x: 0.0,
        y: 0.0,
        z: rotation,
      ),
      scale: design_models.Scale.uniform(scale),
    );

    _placedObjects.add(designObject);
    _isObjectPlaced = true;
    notifyListeners();
  }

  Future<void> placeARObject(FurnitureItem item, vmath.Vector3 position, double scale, double rotation) async {
    if (_arObjectManager == null) {
      print('❌ AR Object Manager is null');
      return;
    }

    if (item.arModelUrl == null || item.arModelUrl!.isEmpty) {
      print('❌ No AR model URL for item: ${item.name}');
      return;
    }

    try {
      print('🔄 Placing AR object: ${item.name}');

      // Create AR node
      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: item.arModelUrl!,
        position: position,
        scale: vmath.Vector3.all(scale),
        rotation: vmath.Vector4(0, 1, 0, rotation * (3.14159265 / 180)),
      );

      await _arObjectManager!.addNode(node);
      _currentNode = node;

      // Also add to placedObjects for backend
      _placedObjects.add(
        design_models.DesignObject(
          itemId: item.id,
          position: design_models.Position(x: position.x, y: position.y, z: position.z),
          rotation: design_models.Rotation(x: 0, y: 0, z: rotation),
          scale: design_models.Scale.uniform(scale),
        ),
      );

      _isObjectPlaced = true;
      print('✅ AR object placed successfully');
      notifyListeners();

    } catch (e) {
      print('❌ Failed to place AR object: $e');
      _error = 'Failed to place object: $e';
      notifyListeners();
    }
  }

  Future<void> removeObject() async {
    if (_currentNode != null) {
      await _arObjectManager!.removeNode(_currentNode!);
      _currentNode = null;
      _placedObjects.removeLast();
    }
    _isObjectPlaced = _placedObjects.isNotEmpty;
    notifyListeners();
  }

  Future<void> clearAllObjects() async {
    if (_arObjectManager == null) return;

    // Remove all placed nodes individually
    for (final node in List<ARNode>.from(_placedObjects)) {
      await _arObjectManager!.removeNode(node);
    }

    // Clear local tracking
    _placedObjects.clear();
    _currentNode = null;
    _isObjectPlaced = false;

    notifyListeners();
  }

  Future<void> moveARObject(Vector3 newPosition) async {
    if (_currentNode == null || _arObjectManager == null) return;

    final oldNode = _currentNode!;

    // Remove the old node safely
    await _arObjectManager!.removeNode(oldNode);

    // Create a new node with updated position
    final newNode = ARNode(
      type: oldNode.type,
      uri: oldNode.uri,
      position: newPosition,
      rotation: _currentRotation,
      scale: oldNode.scale,
    );

    final success = await _arObjectManager!.addNode(newNode) ?? false; // ✅ null-safe fallback

    if (success) {
      _currentNode = newNode;

      // ✅ Update last placed DesignObject position
      if (_placedObjects.isNotEmpty) {
        final lastIndex = _placedObjects.length - 1;
        final lastObject = _placedObjects[lastIndex];

        _placedObjects[lastIndex] = lastObject.copyWith(
          position: design_models.Position(
            x: newPosition.x,
            y: newPosition.y,
            z: newPosition.z,
          ),
        );
      }

      notifyListeners();
    }
  }






  Future<void> rotateARObject(double rotationDegrees) async {
    if (_currentNode != null && _arObjectManager != null) {
      final radians = rotationDegrees * (3.14159265 / 180);
      final newRotation = vmath.Vector4(0, 1, 0, radians);
      _currentRotation = newRotation; // store it
      // rebuild node with new rotation
      await moveARObject(_currentNode!.position);
    }
  }


  Future<void> scaleARObject(double newScale) async {
    if (_currentNode == null || _arObjectManager == null) return;

    final oldNode = _currentNode!;

    // Remove the old node
    await _arObjectManager!.removeNode(oldNode);

    // Create a new node with updated scale
    final newNode = ARNode(
      type: oldNode.type,
      uri: oldNode.uri,
      position: oldNode.position,
      rotation: _currentRotation,
      scale: Vector3.all(newScale),
    );

    final success = await _arObjectManager!.addNode(newNode) ?? false;

    if (success) {
      _currentNode = newNode;

      // Update last DesignObject for backend
      if (_placedObjects.isNotEmpty) {
        final lastIndex = _placedObjects.length - 1;
        final lastObject = _placedObjects[lastIndex];

        _placedObjects[lastIndex] = lastObject.copyWith(
          scale: design_models.Scale.uniform(newScale),
        );
      }

      notifyListeners();
    }
  }


  // ===========================================================
  // CAPTURE & SAVE TO BACKEND
  // ===========================================================
  Future<void> captureImage(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _error = 'Camera not ready';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final XFile image = await _controller!.takePicture();
      _capturedImagePath = image.path;

      print('Image captured: ${image.path}');
      print('Placed objects: ${_placedObjects.length}');
    } catch (e) {
      _error = 'Failed to capture image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }




Future<void> captureARScene() async {
    if (_arSessionManager == null) {
      _error = 'AR Session not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _arSessionManager!.snapshot();
      Uint8List? bytes;

      if (snapshot == null) {
        _error = 'AR snapshot returned null';
        return;
      }

      if (snapshot is Uint8List) {
        bytes = snapshot as Uint8List?;
      } else if (snapshot is ImageProvider) {
        // Convert ImageProvider to Uint8List
        final completer = Completer<Uint8List>();
        final stream = snapshot.resolve(const ImageConfiguration());
        late final ImageStreamListener listener;

        listener = ImageStreamListener((imageInfo, _) async {
          final byteData = await imageInfo.image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (byteData != null) {
            completer.complete(byteData.buffer.asUint8List());
          } else {
            completer.completeError('Failed to convert image to bytes');
          }
          stream.removeListener(listener);
        }, onError: (error, _) {
          completer.completeError(error ?? 'Unknown error');
          stream.removeListener(listener);
        });

        stream.addListener(listener);
        bytes = await completer.future;
      } else {
        _error = 'Unsupported snapshot type: ${snapshot.runtimeType}';
        return;
      }

      if (bytes == null || bytes.isEmpty) {
        _error = 'Captured snapshot is empty';
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/ar_capture_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes); // ✅ safe now
      _capturedImagePath = file.path;

      print('AR Scene captured at: $_capturedImagePath');
    } catch (e) {
      _error = 'Error capturing AR scene: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }





  Future<bool> saveProjectToRoomieLab(BuildContext context) async {
    if (_capturedImagePath == null) {
      _error = 'No image captured';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final roomieLabViewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      final projectName = _generateProjectName();
      final roomType = _determineRoomType();

      final projectId = await roomieLabViewModel.createProject(
        name: projectName,
        roomType: roomType,
        imagePath: _capturedImagePath!,
        designObjects: _placedObjects,
      );

      if (projectId != null) {
        print('Project saved successfully with ID: $projectId');
        return true;
      } else {
        _error = 'Failed to save project to RoomieLab';
        return false;
      }
    } catch (e) {
      _error = 'Failed to save project: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateProjectName() {
    if (_placedObjects.isEmpty) {
      return 'AR Design ${DateTime.now().toString().substring(0, 16)}';
    }

    final mainObject = _placedObjects.first;
    final furnitureItem = _availableFurnitureItems.firstWhere(
          (item) => item.id == mainObject.itemId,
      orElse: () => _availableFurnitureItems.first,
    );
    return '${furnitureItem.name} Design ${DateTime.now().toString().substring(0, 16)}';
  }

  String _determineRoomType() {
    if (_placedObjects.isEmpty) return 'Living Room';

    final objectIds = _placedObjects.map((obj) => obj.itemId).toSet();
    final roomTypes = _availableFurnitureItems
        .where((item) => objectIds.contains(item.id))
        .map((item) => item.roomType)
        .toSet();

    if (roomTypes.contains('Bedroom')) return 'Bedroom';
    if (roomTypes.contains('Living Room')) return 'Living Room';
    if (roomTypes.contains('Dining Room')) return 'Dining Room';
    if (roomTypes.contains('Office')) return 'Office';

    return 'Living Room';
  }

  void resetCapture() {
    _capturedImagePath = null;
    _placedObjects.clear();
    _isObjectPlaced = false;
    notifyListeners();
  }

  void resetAll() {
    _capturedImagePath = null;
    _placedObjects.clear();
    _isObjectPlaced = false;
    if (_availableFurnitureItems.isNotEmpty) {
      _selectedFurnitureItem = _availableFurnitureItems.first;
      _selectedObject = _selectedFurnitureItem!.name;
    }
    notifyListeners();
  }

  // ===========================================================
  // SWITCH CAMERA
  // ===========================================================
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final newCamera = _controller!.description == _cameras!.first
        ? _cameras!.last
        : _cameras!.first;

    await _controller!.dispose();

    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    notifyListeners();
  }

  void onBottomNavigationTapped(int index) {
    _homeViewModel.onTabSelected(index);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
