// CameraViewModel - AR Camera and Furniture Placement Management
//
// PURPOSE: Manages camera functionality, AR object placement, and image capture
//
// FEATURES:
// - Real camera initialization and control
// - Furniture object selection and AR placement
// - Image capture and saving
// - Camera switching (front/back)
//
// BACKEND INTEGRATION POINTS:
// - TO DO: Integrate with /api/ar-objects for 3D model URLs
// - TO DO: Save AR sessions via POST /api/ar-sessions
// - TO DO: Upload captured images to /api/ar-captures
//
// DEPENDENCIES: camera package for hardware access, permission_handler for permissions
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String? _error;
  List<CameraDescription>? _cameras;

  // AR state
  bool _isObjectPlaced = false;
  String _selectedObject = 'Sofa';
  final List<String> _availableObjects = ['Sofa', 'Chair', 'Table', 'Bed', 'Lamp'];

  // Getters
  bool get isCameraReady => _isCameraReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isObjectPlaced => _isObjectPlaced;
  String get selectedObject => _selectedObject;
  List<String> get availableObjects => _availableObjects;
  CameraController? get controller => _controller;

  // Initialize REAL camera
  Future<void> initializeCamera() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _error = 'Camera permission denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _error = 'No cameras available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Initialize camera controller
      _controller = CameraController(
        _cameras!.first, // Use first available camera
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

  // Select object for AR placement
  void selectObject(String object) {
    _selectedObject = object;
    notifyListeners();
  }

  // Place object in AR
  void placeObject() {
    _isObjectPlaced = true;
    notifyListeners();
  }

  // Remove placed object
  void removeObject() {
    _isObjectPlaced = false;
    notifyListeners();
  }

  // Capture image
  Future<void> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _error = 'Camera not ready';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final XFile image = await _controller!.takePicture();
      // You can save or process the image here
      print('Image captured: ${image.path}');
    } catch (e) {
      _error = 'Failed to capture image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Switch camera (front/back)
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}