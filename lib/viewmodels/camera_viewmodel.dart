import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/services/furniture_service.dart';
import 'package:roomantics/models/design_object.dart' as design_models;
import 'package:roomantics/models/furniture_item.dart';

import 'home_viewmodel.dart';

class CameraViewModel extends ChangeNotifier {

  final HomeViewModel _homeViewModel = HomeViewModel.instance;
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isLoading = false;
  String? _error;
  List<CameraDescription>? _cameras;

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
      // Load furniture items from Firestore
      await _loadFurnitureItems();

      // Initialize camera
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
        ResolutionPreset.medium,
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
      if (_availableFurnitureItems.isNotEmpty) {
        _selectedFurnitureItem = _availableFurnitureItems.first;
        _selectedObject = _selectedFurnitureItem!.name;
      }
    } catch (e) {
      print('Error loading furniture items: $e');
      // Fallback to basic items if Firestore fails
      _availableFurnitureItems = [
        FurnitureItem(
          id: 'default_sofa',
          name: 'Sofa',
          description: 'Comfortable sofa',
          category: 'Furniture',
          roomType: 'Living Room',
          imageUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FurnitureItem(
          id: 'default_chair',
          name: 'Chair',
          description: 'Comfortable chair',
          category: 'Furniture',
          roomType: 'Living Room',
          imageUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FurnitureItem(
          id: 'default_table',
          name: 'Table',
          description: 'Dining table',
          category: 'Furniture',
          roomType: 'Dining Room',
          imageUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FurnitureItem(
          id: 'default_bed',
          name: 'Bed',
          description: 'Comfortable bed',
          category: 'Furniture',
          roomType: 'Bedroom',
          imageUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FurnitureItem(
          id: 'default_lamp',
          name: 'Lamp',
          description: 'Table lamp',
          category: 'Lighting',
          roomType: 'Living Room',
          imageUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _selectedFurnitureItem = _availableFurnitureItems.first;
    }
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

      // Store the captured image path for preview
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

      // Generate project name based on objects placed
      final projectName = _generateProjectName();
      final roomType = _determineRoomType();

      // Save project to backend
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

    // Get room types from placed furniture items
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