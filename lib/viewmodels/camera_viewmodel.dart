import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/furniture_item.dart';
import '../services/furniture_service.dart';

class CameraViewModel extends ChangeNotifier {
  ARSessionManager? _arSessionManager;
  ARAnchorManager? _arAnchorManager;
  ARObjectManager? _arObjectManager;
  ARNode? _placedNode;

  bool _isObjectPlaced = false;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String? _error;
  FurnitureItem? _selectedFurnitureItem;
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  final FurnitureService _furnitureService = FurnitureService();
  List<FurnitureItem> _availableFurnitureItems = [];

  bool get isObjectPlaced => _isObjectPlaced;
  bool get isCameraReady => _isCameraReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FurnitureItem? get selectedFurnitureItem => _selectedFurnitureItem;
  List<FurnitureItem> get availableFurnitureItems => _availableFurnitureItems;
  CameraController? get controller => _controller;

  // =========================
  // FURNITURE LOADING
  // =========================
  Future<void> loadFurnitureItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableFurnitureItems = await _furnitureService.getFurnitureItems();
      
      // Filter items that have AR model URLs
      _availableFurnitureItems = _availableFurnitureItems
          .where((item) => item.arModelUrl != null && item.arModelUrl!.isNotEmpty)
          .toList();
      
      // Set the first item as selected if available
      if (_availableFurnitureItems.isNotEmpty) {
        _selectedFurnitureItem = _availableFurnitureItems.first;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load furniture items: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // CAMERA INITIALIZATION
  // =========================
  Future<void> initializeCamera() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _error = 'Camera permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _error = 'No cameras available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isCameraReady = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize camera: $e';
      _isCameraReady = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // AR SETUP
  // =========================
  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,


    );

    _arObjectManager!.onInitialize();
  }

  void selectFurnitureItem(FurnitureItem furnitureItem) {
    _selectedFurnitureItem = furnitureItem;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =========================
  // CAMERA CONTROLS
  // =========================
  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      // Handle the captured image here
      // You can save it, show a preview, etc.
      print('Image captured: ${image.path}');
    } catch (e) {
      _error = 'Failed to capture image: $e';
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final currentIndex = _cameras!.indexOf(_controller!.description);
      final newIndex = (currentIndex + 1) % _cameras!.length;
      
      await _controller!.dispose();
      
      _controller = CameraController(
        _cameras![newIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to switch camera: $e';
      notifyListeners();
    }
  }

  // =========================
  // PLACE OBJECT
  // =========================
  Future<void> placeObject() async {
    if (_isObjectPlaced || _selectedFurnitureItem == null) return;

    final modelUrl = _selectedFurnitureItem!.arModelUrl;
    if (modelUrl == null || modelUrl.isEmpty) {
      _error = 'No 3D model available for this item';
      notifyListeners();
      return;
    }

    final node = ARNode(
      type: NodeType.webGLB,
      uri: modelUrl,
      scale: Vector3(0.5, 0.5, 0.5),
      position: Vector3(0.0, 0.0, 0.0),
      rotation: Vector4(0.0, 0.0, 0.0, 0.0),
    );

    try {
      await _arObjectManager!.addNode(node);
      _placedNode = node;
      _isObjectPlaced = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to place object: $e';
      notifyListeners();
    }
  }

  Future<void> removeObject() async {
    if (_placedNode != null) {
      await _arObjectManager!.removeNode(_placedNode!);
      _placedNode = null;
      _isObjectPlaced = false;
      notifyListeners();
    }
  }

  void disposeAR() {
    _arSessionManager?.dispose();
    // ARObjectManager doesn't have a dispose method
  }

  @override
  void dispose() {
    disposeAR();
    _controller?.dispose();
    super.dispose();
  }
}
