import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:Roomantics/services/furniture_service.dart';
import 'package:Roomantics/models/design.dart';
import 'package:Roomantics/models/design_object.dart';
import 'package:Roomantics/models/furniture_item.dart';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String? _error;
  List<CameraDescription>? _cameras;

  // AR state
  bool _isObjectPlaced = false;
  bool _isFurnitureSelectionVisible = false;
  FurnitureItem? _selectedFurnitureItem;
  List<FurnitureItem> _availableFurnitureItems = [];

  // Capture state
  String? _capturedImagePath;
  List<DesignObject> _placedObjects = [];

  // Getters
  bool get isCameraReady => _isCameraReady;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isObjectPlaced => _isObjectPlaced;
  bool get isFurnitureSelectionVisible => _isFurnitureSelectionVisible;
  FurnitureItem? get selectedFurnitureItem => _selectedFurnitureItem;
  List<FurnitureItem> get availableFurnitureItems => _availableFurnitureItems;
  CameraController? get controller => _controller;
  String? get capturedImagePath => _capturedImagePath;
  bool get hasCapturedImage => _capturedImagePath != null;
  List<DesignObject> get placedObjects => _placedObjects;

  final FurnitureService _furnitureService = FurnitureService();

  // ===========================================================
  // CAMERA INITIALIZATION
  // ===========================================================
  Future<void> initializeCamera() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load furniture items
      await _loadFurnitureItems();

      // Check camera permission
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

  Future<void> _loadFurnitureItems() async {
    try {
      _availableFurnitureItems = await _furnitureService.getFurnitureItems();

      // Filter items that have 3D models (GLB files)
      _availableFurnitureItems = _availableFurnitureItems.where((item) {
        return item.arModelUrl != null && item.arModelUrl!.isNotEmpty;
      }).toList();

      if (_availableFurnitureItems.isNotEmpty) {
        _selectedFurnitureItem = _availableFurnitureItems.first;
      }
    } catch (e) {
      print('Error loading furniture items: $e');
      // Fallback to demo items with 3D models
      _availableFurnitureItems = _getDemoFurnitureItems();
      _selectedFurnitureItem = _availableFurnitureItems.first;
    }
  }

  List<FurnitureItem> _getDemoFurnitureItems() {
    return [
      FurnitureItem(
        id: 'sofa_001',
        name: 'Modern Sofa',
        description: '3-seater modern sofa',
        category: 'Sofa',
        roomType: 'Living Room',
        imageUrl: null,
        arModelUrl: 'assets/models/sofa.glb', // Path to GLB file
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      FurnitureItem(
        id: 'chair_001',
        name: 'Dining Chair',
        description: 'Modern dining chair',
        category: 'Chair',
        roomType: 'Dining Room',
        imageUrl: null,
        arModelUrl: 'assets/models/chair.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      FurnitureItem(
        id: 'table_001',
        name: 'Coffee Table',
        description: 'Round coffee table',
        category: 'Table',
        roomType: 'Living Room',
        imageUrl: null,
        arModelUrl: 'assets/models/table.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      FurnitureItem(
        id: 'bed_001',
        name: 'Double Bed',
        description: 'Queen size bed',
        category: 'Bed',
        roomType: 'Bedroom',
        imageUrl: null,
        arModelUrl: 'assets/models/bed.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      FurnitureItem(
        id: 'lamp_001',
        name: 'Floor Lamp',
        description: 'Modern floor lamp',
        category: 'Lighting',
        roomType: 'Living Room',
        imageUrl: null,
        arModelUrl: 'assets/models/lamp.glb',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // ===========================================================
  // FURNITURE SELECTION UI
  // ===========================================================
  void toggleFurnitureSelection() {
    _isFurnitureSelectionVisible = !_isFurnitureSelectionVisible;
    notifyListeners();
  }

  void hideFurnitureSelection() {
    _isFurnitureSelectionVisible = false;
    notifyListeners();
  }

  void selectFurnitureItem(FurnitureItem item) {
    _selectedFurnitureItem = item;
    notifyListeners();
  }

  // ===========================================================
  // AR OBJECT MANAGEMENT
  // ===========================================================
  void placeObject(Offset position, double scale, double rotation) {
    if (_selectedFurnitureItem == null) return;

    final designObject = DesignObject(
      itemId: _selectedFurnitureItem!.id,
      position: Position(
        x: position.dx,
        y: position.dy,
        z: 0.0,
      ),
      rotation: Rotation(
        x: 0.0,
        y: 0.0,
        z: rotation,
      ),
      scale: Scale.uniform(scale),
      arModelUrl: _selectedFurnitureItem!.arModelUrl, // Store GLB path
    );

    _placedObjects.add(designObject);
    _isObjectPlaced = true;
    notifyListeners();
  }

  void removeObject() {
    if (_placedObjects.isNotEmpty) {
      _placedObjects.removeLast();
    }
    _isObjectPlaced = _placedObjects.isNotEmpty;
    notifyListeners();
  }

  void clearAllObjects() {
    _placedObjects.clear();
    _isObjectPlaced = false;
    notifyListeners();
  }

  // ===========================================================
  // CAPTURE & SAVE
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

      // Create a design with all placed objects
      final design = Design(
        id: '', // Will be generated by Firestore
        userId: 'current_user_id', // You'll need to get this from auth
        projectId: '', // Will be set after project creation
        name: _generateProjectName(),
        objects: _placedObjects,
        imageUrl: _capturedImagePath!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastViewed: DateTime.now(),
      );

      // First create the project
      final projectId = await roomieLabViewModel.createProject(
        name: design.name,
        roomType: _determineRoomType(),
        imageUrl: _capturedImagePath!,
        items: _placedObjects.map((obj) => obj.itemId).toList(),
        description: 'AR design with ${_placedObjects.length} objects',
      );

      if (projectId != null) {
        // Now create the design with the project ID
        final designId = await roomieLabViewModel.createDesign(
          projectId: projectId,
          name: design.name,
          objects: _placedObjects,
          imageUrl: _capturedImagePath!,
        );

        if (designId != null) {
          print('Project and design saved successfully');
          print('Project ID: $projectId, Design ID: $designId');
          print('Saved ${_placedObjects.length} 3D objects');

          // Reset for next capture
          resetCapture();
          return true;
        }
      }

      _error = 'Failed to save project to RoomieLab';
      return false;
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

    final objectNames = _placedObjects.map((obj) {
      final furniture = _availableFurnitureItems.firstWhere(
            (item) => item.id == obj.itemId,
        orElse: () => _availableFurnitureItems.first,
      );
      return furniture.name;
    }).toList();

    final mainObject = objectNames.first;
    if (objectNames.length == 1) {
      return '$mainObject Design';
    } else {
      return '$mainObject +${objectNames.length - 1} more';
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

    // Return the most common room type, or default to Living Room
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
    _isFurnitureSelectionVisible = false;
    notifyListeners();
  }

  // ===========================================================
  // CAMERA CONTROLS
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