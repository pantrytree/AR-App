import 'dart:async';
import 'dart:math' as math;
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

  List<ARNode> _placedNodes = [];
  int _selectedNodeIndex = -1;

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
  int get selectedNodeIndex => _selectedNodeIndex;
  ARNode? get selectedNode => _selectedNodeIndex >= 0 && _selectedNodeIndex < _placedNodes.length
      ? _placedNodes[_selectedNodeIndex]
      : null;

  String? _capturedImagePath;
  String? get capturedImagePath => _capturedImagePath;

  List<ARNode> get placedNodes => _placedNodes;
  bool get isObjectPlaced => _placedNodes.isNotEmpty;
  List<FurnitureItem> get availableFurnitureItems => _availableFurnitureItems;
  FurnitureItem? get selectedFurnitureItem => _selectedFurnitureItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  void selectNode(int index) {
    if (index >= 0 && index < _placedNodes.length) {
      _selectedNodeIndex = index;
      print('Selected node at index: $index');
      notifyListeners();
    }
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

    // Set up node tap handler
    _arObjectManager!.onNodeTap = (nodeName) {
      final index = _placedNodes.indexWhere((node) => node.name == nodeName);
      if (index != -1) {
        selectNode(index);
      }
    };

    print('AR managers initialized');
    notifyListeners();
  }

  Future<void> placeFurniture() async {
    print('PLACE FURNITURE CALLED');

    try {
      if (_arObjectManager == null) {
        print('ERROR: AR Object Manager is null!');
        _error = 'AR not initialized. Please restart the app.';
        notifyListeners();
        return;
      }

      if (_selectedFurnitureItem == null) {
        _error = 'Please select a furniture item first';
        notifyListeners();
        return;
      }

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      String? furnitureItemId = _selectedFurnitureItem!.id;

      if (_selectedFurnitureItem!.arModelUrl != null &&
          _selectedFurnitureItem!.arModelUrl!.isNotEmpty) {
        modelUrl = _cloudinaryService.getArModelUrl(_selectedFurnitureItem!.arModelUrl!);
      }

      final position = _calculateNewObjectPosition();

      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: Vector3(_currentScale, _currentScale, _currentScale),
        position: position,
        rotation: Vector4(0, 1, 0, _currentRotationAngle),
        name: 'furniture_${DateTime.now().millisecondsSinceEpoch}',
      );

      final didAdd = await _arObjectManager!.addNode(node).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          print('addNode() timed out');
          return false;
        },
      );

      if (didAdd == true) {
        _placedNodes.add(node);
        _selectedNodeIndex = _placedNodes.length - 1;
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
        print('FURNITURE PLACED SUCCESSFULLY! Total objects: ${_placedNodes.length}');
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

  Future<void> removeLastFurniture() async {
    if (_placedNodes.isEmpty || _arObjectManager == null) return;

    try {
      final lastNode = _placedNodes.last;
      await _arObjectManager!.removeNode(lastNode);
      _placedNodes.removeLast();
      _currentDesignObjects.removeLast();

      // Update selected index
      if (_selectedNodeIndex >= _placedNodes.length) {
        _selectedNodeIndex = _placedNodes.isEmpty ? -1 : _placedNodes.length - 1;
      }

      print('Removed last furniture object. Remaining: ${_placedNodes.length}');
      notifyListeners();
    } catch (e) {
      print('Error removing furniture: $e');
    }
  }

  Future<void> removeSelectedFurniture() async {
    if (_selectedNodeIndex == -1 || _arObjectManager == null) return;

    try {
      final nodeToRemove = _placedNodes[_selectedNodeIndex];
      await _arObjectManager!.removeNode(nodeToRemove);
      _placedNodes.removeAt(_selectedNodeIndex);
      _currentDesignObjects.removeAt(_selectedNodeIndex);

      // Update selected index
      if (_placedNodes.isEmpty) {
        _selectedNodeIndex = -1;
      } else if (_selectedNodeIndex >= _placedNodes.length) {
        _selectedNodeIndex = _placedNodes.length - 1;
      }

      print('Removed selected furniture object. Remaining: ${_placedNodes.length}');
      notifyListeners();
    } catch (e) {
      print('Error removing selected furniture: $e');
    }
  }

  Future<void> removeAllFurniture() async {
    if (_arObjectManager == null) return;

    try {
      for (final node in _placedNodes) {
        await _arObjectManager!.removeNode(node);
      }
      _placedNodes.clear();
      _currentDesignObjects.clear();
      _selectedNodeIndex = -1;
      _currentRotationAngle = 0.0;
      _currentScale = 0.5;

      print('Removed all furniture objects');
      notifyListeners();
    } catch (e) {
      print('Error removing all furniture: $e');
    }
  }

  Vector3 _calculateNewObjectPosition() {
    if (_placedNodes.isEmpty) {
      return Vector3(0, -0.5, -2);
    }

    // Offset new objects slightly from the last one
    final lastPosition = _placedNodes.last.position;
    return Vector3(
      lastPosition.x + 0.3,
      lastPosition.y,
      lastPosition.z,
    );
  }

  Future<void> scaleFurniture(double scaleDelta) async {
    try {
      final nodeToScale = selectedNode ?? (_placedNodes.isNotEmpty ? _placedNodes.last : null);
      if (nodeToScale == null || _arObjectManager == null) {
        print('Cannot scale: no object placed or AR not initialized');
        return;
      }

      print('SCALING FURNITURE');

      await _arObjectManager!.removeNode(nodeToScale);

      final newScaleValue = (nodeToScale.scale.x + scaleDelta).clamp(0.1, 2.0);
      print('New scale: $newScaleValue');

      // Handle rotation type conversion
      Vector4 rotation;
      if (nodeToScale.rotation is Vector4) {
        rotation = nodeToScale.rotation as Vector4;
      } else if (nodeToScale.rotation is Matrix3) {
        final matrix = nodeToScale.rotation as Matrix3;
        final angle = math.atan2(matrix[2], matrix[8]);
        rotation = Vector4(0, 1, 0, angle);
      } else {
        rotation = Vector4(0, 1, 0, 0);
      }

      final newNode = ARNode(
        type: nodeToScale.type,
        uri: nodeToScale.uri,
        scale: Vector3(newScaleValue, newScaleValue, newScaleValue),
        position: nodeToScale.position,
        rotation: rotation,
        name: nodeToScale.name,
      );

      bool didAdd = await _arObjectManager!.addNode(newNode) ?? false;
      if (didAdd) {
        final index = _placedNodes.indexOf(nodeToScale);
        _placedNodes[index] = newNode;

        if (index < _currentDesignObjects.length) {
          final updatedObject = _currentDesignObjects[index].copyWith(
            scale: Scale(
              x: newScaleValue,
              y: newScaleValue,
              z: newScaleValue,
            ),
          );
          _currentDesignObjects[index] = updatedObject;
        }

        print('Furniture scaled successfully to $newScaleValue');
      } else {
        _placedNodes.remove(nodeToScale);
        _error = 'Failed to scale furniture';
      }

      notifyListeners();
    } catch (e) {
      print('Error scaling furniture: $e');
      _error = 'Failed to scale furniture: $e';
      notifyListeners();
    }
  }

  Future<void> moveFurniture(double deltaX, double deltaY, double deltaZ) async {
    final nodeToMove = selectedNode ?? (_placedNodes.isNotEmpty ? _placedNodes.last : null);
    if (nodeToMove == null || _arObjectManager == null) return;

    final currentPos = nodeToMove.position;
    final newPos = Vector3(
      currentPos.x + deltaX,
      currentPos.y + deltaY,
      currentPos.z + deltaZ,
    );

    await _arObjectManager!.removeNode(nodeToMove);

    Vector4 rotation;
    if (nodeToMove.rotation is Vector4) {
      rotation = nodeToMove.rotation as Vector4;
    } else if (nodeToMove.rotation is Matrix3) {
      final matrix = nodeToMove.rotation as Matrix3;
      final angle = math.atan2(matrix[2], matrix[8]);
      rotation = Vector4(0, 1, 0, angle);
    } else {
      rotation = Vector4(0, 1, 0, 0);
    }

    final newNode = ARNode(
      type: nodeToMove.type,
      uri: nodeToMove.uri,
      scale: nodeToMove.scale,
      position: newPos,
      rotation: rotation,
      name: nodeToMove.name,
    );

    bool didAdd = await _arObjectManager!.addNode(newNode) ?? false;
    if (didAdd) {
      final index = _placedNodes.indexOf(nodeToMove);
      _placedNodes[index] = newNode;

      // Update design object position
      if (index < _currentDesignObjects.length) {
        final updatedObject = _currentDesignObjects[index].copyWith(
          position: Position(
            x: newPos.x,
            y: newPos.y,
            z: newPos.z,
          ),
        );
        _currentDesignObjects[index] = updatedObject;
      }

      print('Furniture moved and design object updated');
    } else {
      _placedNodes.remove(nodeToMove);
    }
    notifyListeners();
  }

  Future<void> rotateFurniture(double angleRadians) async {
    try {
      final nodeToRotate = selectedNode ?? (_placedNodes.isNotEmpty ? _placedNodes.last : null);
      if (nodeToRotate == null || _arObjectManager == null) return;

      await _arObjectManager!.removeNode(nodeToRotate);

      double currentRotation;
      if (nodeToRotate.rotation is Vector4) {
        currentRotation = (nodeToRotate.rotation as Vector4).w;
      } else if (nodeToRotate.rotation is Matrix3) {
        final matrix = nodeToRotate.rotation as Matrix3;
        currentRotation = math.atan2(matrix[2], matrix[8]);
      } else {
        currentRotation = 0.0;
      }

      final newRotation = currentRotation + angleRadians;

      final newNode = ARNode(
        type: nodeToRotate.type,
        uri: nodeToRotate.uri,
        scale: nodeToRotate.scale,
        position: nodeToRotate.position,
        rotation: Vector4(0, 1, 0, newRotation),
        name: nodeToRotate.name,
      );

      bool didAdd = await _arObjectManager!.addNode(newNode) ?? false;
      if (didAdd) {
        final index = _placedNodes.indexOf(nodeToRotate);
        _placedNodes[index] = newNode;

        if (index < _currentDesignObjects.length) {
          final updatedObject = _currentDesignObjects[index].copyWith(
            rotation: Rotation(
              x: 0,
              y: newRotation,
              z: 0,
            ),
          );
          _currentDesignObjects[index] = updatedObject;
        }

        print('Furniture rotated and design object updated');
      } else {
        _placedNodes.remove(nodeToRotate);
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
      final imageProvider = await _arSessionManager!.snapshot();

      if (imageProvider == null) {
        _error = 'Failed to capture screenshot';
        print('Screenshot is null');
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('Screenshot captured, type: ${imageProvider.runtimeType}');

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

      final ui.Image image = await completer.future;
      print('Image loaded: ${image.width}x${image.height}');

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

      final designId = 'ar_design_${DateTime.now().millisecondsSinceEpoch}';
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

      final imageFile = File(_capturedImagePath!);
      final imageUrl = await _uploadImageToCloudinary(imageFile);

      final projectId = await _projectService.createProject(
        name: '$designName Project',
        roomType: _determineRoomType(),
        description: 'AR design created with RoomieLab',
        imageUrl: imageUrl,
        useFirestore: true,
      );

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

  Future<bool> saveToGallery() async {
    if (_lastScreenshot == null) {
      _error = 'No screenshot available';
      notifyListeners();
      return false;
    }

    print(' SAVING SCREENSHOT TO GALLERY ');

    try {
      final PermissionStatus status = await Permission.photos.request();

      if (!status.isGranted && !status.isLimited) {
        print('Permission denied: $status');
        _error = 'Storage permission denied';
        notifyListeners();
        return false;
      }

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
    await removeAllFurniture();
    _error = null;
    notifyListeners();
  }

  // Get current design state
  Map<String, dynamic> getCurrentDesignState() {
    return {
      'objects': _currentDesignObjects.map((obj) => obj.toMap()).toList(),
      'isObjectPlaced': isObjectPlaced,
      'selectedFurniture': _selectedFurnitureItem?.toFirestore(),
    };
  }

  Future<void> loadDesignForEditing(String designId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final design = await _designService.getDesign(designId, useFirestore: true);
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
