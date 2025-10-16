import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';

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

  // Capture state
  String? _capturedImagePath;

  // Getters
  bool get isCameraReady => _isCameraReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isObjectPlaced => _isObjectPlaced;
  String get selectedObject => _selectedObject;
  List<String> get availableObjects => _availableObjects;
  CameraController? get controller => _controller;
  String? get capturedImagePath => _capturedImagePath;
  bool get hasCapturedImage => _capturedImagePath != null;

  // ===========================================================
  // CAMERA SETUP
  // ===========================================================
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

  // ===========================================================
  // AR OBJECT MANAGEMENT
  // ===========================================================
  void selectObject(String object) {
    _selectedObject = object;
    notifyListeners();
  }

  void placeObject() {
    _isObjectPlaced = true;
    notifyListeners();
  }

  void removeObject() {
    _isObjectPlaced = false;
    notifyListeners();
  }

  // ===========================================================
  // CAPTURE
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

      // Store the captured image path for preview
      _capturedImagePath = image.path;

      // Once the image is captured, send it to RoomieLabViewModel
      final roomieLab = Provider.of<RoomieLabViewModel>(context, listen: false);
      roomieLab.addProject(
        image.path,
        _selectedObject,
      );

      print('Image captured: ${image.path}');
    } catch (e) {
      _error = 'Failed to capture image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetCapture() {
    _capturedImagePath = null;
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}