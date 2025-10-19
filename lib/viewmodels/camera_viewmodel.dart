import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Roomantics/services/design_service.dart';
import 'package:Roomantics/services/project_service.dart';
import 'package:Roomantics/services/furniture_service.dart';
import 'package:Roomantics/services/cloudinary_service.dart';
import 'package:Roomantics/models/furniture_item.dart';
import 'package:Roomantics/models/design_object.dart';
import 'package:Roomantics/models/design.dart';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String? _error;
  List<CameraDescription>? _cameras;
  CameraLensDirection _currentLens = CameraLensDirection.back;

  // Furniture selection state
  bool _isFurnitureSelectionVisible = false;
  FurnitureItem? _selectedFurnitureItem;
  List<FurnitureItem> _availableFurnitureItems = [];

  // AR state
  List<DesignObject> _placedObjects = [];
  String? _capturedImagePath;

  // Services
  final FurnitureService _furnitureService = FurnitureService();
  final DesignService _designService = DesignService();
  final ProjectService _projectService = ProjectService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getters
  bool get isCameraReady => _isCameraReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFurnitureSelectionVisible => _isFurnitureSelectionVisible;
  FurnitureItem? get selectedFurnitureItem => _selectedFurnitureItem;
  List<FurnitureItem> get availableFurnitureItems => _availableFurnitureItems;
  CameraController? get controller => _controller;
  List<DesignObject> get placedObjects => _placedObjects;
  String? get capturedImagePath => _capturedImagePath;
  bool get hasPlacedObjects => _placedObjects.isNotEmpty;

  // Initialize camera
  Future<void> initializeCamera() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Dispose existing controller
      await _disposeCamera();

      // Check camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _error = 'Camera permission denied. Please enable camera access in settings.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _error = 'No cameras available on this device';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Find back camera first, fallback to first available
      final backCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _currentLens = backCamera.lensDirection;

      // Initialize camera controller
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isCameraReady = true;

      // Load furniture items
      await _loadFurnitureItems();

    } catch (e) {
      _error = 'Failed to initialize camera: ${e.toString()}';
      _isCameraReady = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load furniture items with AR models
  Future<void> _loadFurnitureItems() async {
    try {
      _availableFurnitureItems = await _furnitureService.getFurnitureItems();

      // Filter items that have AR models
      _availableFurnitureItems = _availableFurnitureItems.where((item) {
        return item.arModelUrl != null && item.arModelUrl!.isNotEmpty;
      }).toList();

      // If no AR models found, create demo items
      if (_availableFurnitureItems.isEmpty) {
        _availableFurnitureItems = _createDemoFurnitureItems();
      }

      // Select first item by default
      if (_availableFurnitureItems.isNotEmpty) {
        _selectedFurnitureItem = _availableFurnitureItems.first;
      }
    } catch (e) {
      _availableFurnitureItems = _createDemoFurnitureItems();
      _selectedFurnitureItem = _availableFurnitureItems.first;
    }
    notifyListeners();
  }

  List<FurnitureItem> _createDemoFurnitureItems() {
    return [
      FurnitureItem(
        id: 'sofa_001',
        name: 'Modern Sofa',
        description: '3-seater modern sofa with AR model',
        category: 'Sofa',
        roomType: 'Living Room',
        imageUrl: null,
        arModelUrl: 'https://example.com/models/sofa.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      FurnitureItem(
        id: 'chair_001',
        name: 'Dining Chair',
        description: 'Modern dining chair with AR model',
        category: 'Chair',
        roomType: 'Dining Room',
        imageUrl: null,
        arModelUrl: 'https://example.com/models/chair.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      FurnitureItem(
        id: 'table_001',
        name: 'Coffee Table',
        description: 'Round coffee table with AR model',
        category: 'Table',
        roomType: 'Living Room',
        imageUrl: null,
        arModelUrl: 'https://example.com/models/table.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _disposeCamera();

      // Find next camera
      final nextCamera = _cameras!.firstWhere(
            (camera) => camera.lensDirection != _currentLens,
        orElse: () => _cameras!.first,
      );

      _currentLens = nextCamera.lensDirection;

      _controller = CameraController(
        nextCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isCameraReady = true;
    } catch (e) {
      _error = 'Failed to switch camera: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Furniture selection methods
  void toggleFurnitureSelection() {
    _isFurnitureSelectionVisible = !_isFurnitureSelectionVisible;
    notifyListeners();
  }

  void selectFurnitureItem(FurnitureItem item) {
    _selectedFurnitureItem = item;
    _isFurnitureSelectionVisible = false;
    notifyListeners();
  }

  // AR object placement (simplified - without actual 3D rendering)
  void placeObject(Offset position) {
    if (_selectedFurnitureItem == null) return;

    final designObject = DesignObject(
      itemId: _selectedFurnitureItem!.id,
      position: Position(
        x: position.dx,
        y: position.dy,
        z: 0.0,
      ),
      rotation: Rotation(x: 0.0, y: 0.0, z: 0.0),
      scale: Scale.uniform(1.0),
    );

    _placedObjects.add(designObject);
    notifyListeners();
  }

  void removeLastObject() {
    if (_placedObjects.isNotEmpty) {
      _placedObjects.removeLast();
      notifyListeners();
    }
  }

  void clearAllObjects() {
    _placedObjects.clear();
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
      final XFile imageFile = await _controller!.takePicture();
      _capturedImagePath = imageFile.path;
      print('Image captured: ${imageFile.path}');
    } catch (e) {
      _error = 'Failed to capture image: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // REAL Cloudinary upload implementation
  Future<String> _uploadToCloudinary(File imageFile) async {
    try {
      print('Starting Cloudinary upload for camera design...');

      // Generate unique design ID for the upload
      final designId = 'camera_design_${DateTime.now().millisecondsSinceEpoch}';

      // Use the design image upload method from CloudinaryService
      final imageUrl = await _cloudinaryService.uploadDesignImage(imageFile, designId);

      print('Cloudinary upload successful: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Cloudinary upload failed: $e');
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  // Save design to RoomieLab
  Future<bool> saveDesignToRoomieLab(String designName) async {
    if (_capturedImagePath == null) {
      _error = 'No image captured';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Cloudinary using the real implementation
      final imageFile = File(_capturedImagePath!);
      final imageUrl = await _uploadToCloudinary(imageFile);

      // Create a project for this design
      final projectId = await _projectService.createProject(
        name: '$designName Project',
        roomType: _determineRoomType(),
        description: 'AR design created with camera',
        imageUrl: imageUrl,
      );

      // Create the design with placed objects
      final designId = await _designService.createDesign(
        name: designName,
        projectId: projectId,
        objects: _placedObjects,
        imageUrl: imageUrl,
      );

      print('Design saved successfully: $designId');
      print('Image URL: $imageUrl');
      print('Objects placed: ${_placedObjects.length}');

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

  String _determineRoomType() {
    if (_placedObjects.isEmpty) return 'Living Room';

    final roomTypes = _placedObjects.map((obj) {
      final furniture = _availableFurnitureItems.firstWhere(
            (item) => item.id == obj.itemId,
        orElse: () => _availableFurnitureItems.first,
      );
      return furniture.roomType;
    }).toSet();

    // Return most common room type or default
    if (roomTypes.contains('Living Room')) return 'Living Room';
    if (roomTypes.contains('Bedroom')) return 'Bedroom';
    if (roomTypes.contains('Dining Room')) return 'Dining Room';
    if (roomTypes.contains('Office')) return 'Office';

    return 'Living Room';
  }

  // Reset after capture
  void resetCapture() {
    _capturedImagePath = null;
    _placedObjects.clear();
    _isFurnitureSelectionVisible = false;
    notifyListeners();
  }

  // Dispose camera
  Future<void> _disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isCameraReady = false;
  }

  void disposeCamera() {
    _disposeCamera();
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }
}