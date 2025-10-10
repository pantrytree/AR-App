import 'package:flutter/foundation.dart';

class CameraViewModel extends ChangeNotifier {
  // Camera state
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  String? _error;

  // AR Placeholder state
  bool _isARModeActive = false;
  bool _isObjectPlaced = false;
  String _selectedObject = 'Sofa';
  final List<String> _availableObjects = ['Sofa', 'Chair', 'Table', 'Bed', 'Lamp'];

  // Getters
  bool get isCameraInitialized => _isCameraInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isARModeActive => _isARModeActive;
  bool get isObjectPlaced => _isObjectPlaced;
  String get selectedObject => _selectedObject;
  List<String> get availableObjects => _availableObjects;

  // Initialize camera (placeholder for real camera initialization)
  Future<void> initializeCamera() async {
    if (_isCameraInitialized) return; // ✅ Prevent re-initialization

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate camera initialization delay - REDUCED FROM 2 SECONDS
      await Future.delayed(const Duration(milliseconds: 500)); // ✅ Faster

      _isCameraInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize camera: $e';
      _isCameraInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle between Camera and AR modes
  void toggleARMode() {
    _isARModeActive = !_isARModeActive;
    _isObjectPlaced = false;
    notifyListeners();
  }

  // Select object for AR placement
  void selectObject(String object) {
    _selectedObject = object;
    notifyListeners();
  }

  // Place object in AR (placeholder)
  void placeObject() {
    _isObjectPlaced = true;
    notifyListeners();
  }

  // Remove placed object
  void removeObject() {
    _isObjectPlaced = false;
    notifyListeners();
  }

  // Capture image (placeholder)
  Future<void> captureImage() async {
    if (!_isCameraInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate image capture delay
      await Future.delayed(const Duration(milliseconds: 500)); // ✅ Faster

      // Show success feedback
    } catch (e) {
      _error = 'Failed to capture image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset camera
  void resetCamera() {
    _isCameraInitialized = false;
    _isARModeActive = false;
    _isObjectPlaced = false;
    _error = null;
    notifyListeners();
  }

  // Simulate AR object loading (placeholder for real 3D model loading)
  Future<void> loadARObject(String objectName) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate loading 3D model
      await Future.delayed(const Duration(seconds: 1));

      _selectedObject = objectName;
      if (kDebugMode) {
        print('📦 AR Object Loaded: $objectName');
      }
    } catch (e) {
      _error = 'Failed to load AR object: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}