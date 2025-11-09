import 'dart:io';

import 'package:Roomantics/services/cloudinary_service.dart';
import 'package:Roomantics/services/design_service.dart';
import 'package:Roomantics/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'dart:math' as math;

import '/viewmodels/roomielab_viewmodel.dart';
import '/viewmodels/camera_viewmodel.dart';
import '/models/design.dart';
import '/models/design_object.dart';
import '/models/furniture_item.dart';
import '/models/project.dart';

class ProjectEditPage extends StatefulWidget {
  final String projectId;
  final String? initialDesignId;

  const ProjectEditPage({
    super.key,
    required this.projectId,
    this.initialDesignId,
  });

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  // AR managers for handling augmented reality functionality
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  // Services for design and image management
  DesignService _designService = DesignService();
  CloudinaryService _cloudinaryService = CloudinaryService();
  
  // Data storage for designs and project
  List<Design> _designs = [];
  Design? _selectedDesign;
  Project? _currentProject;
  List<ARNode> _arNodes = [];
  
  // UI state flags
  bool _isLoading = true;
  bool _arInitialized = false;
  String? _selectedObjectId;
  bool _isCapturingScreenshot = false;

  // Track object transformations for movement, rotation and scaling
  Map<String, Vector3> _objectPositions = {};
  Map<String, double> _objectRotations = {};
  Map<String, Vector3> _objectScales = {};

  @override
  void initState() {
    super.initState();
    _loadProjectAndDesigns();
  }

  // Load project details and associated designs
  Future<void> _loadProjectAndDesigns() async {
    try {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

      // Load project details
      _currentProject = await viewModel.getProject(widget.projectId);

      // Load designs for this project
      _designs = await viewModel.getProjectDesigns(widget.projectId);

      if (_designs.isNotEmpty) {
        // Select initial design based on provided ID or use first design
        _selectedDesign = widget.initialDesignId != null
            ? _designs.firstWhere(
              (design) => design.id == widget.initialDesignId,
          orElse: () => _designs.first,
        )
            : _designs.first;

        // Initialize object transformations from design data
        _initializeObjectTransformations();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading project and designs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Initialize transformation maps from design object data
  void _initializeObjectTransformations() {
    if (_selectedDesign == null) return;

    _objectPositions.clear();
    _objectRotations.clear();
    _objectScales.clear();

    for (final designObject in _selectedDesign!.objects) {
      _objectPositions[designObject.itemId] = Vector3(
        designObject.position.x,
        designObject.position.y,
        designObject.position.z,
      );
      _objectRotations[designObject.itemId] = designObject.rotation.y;
      _objectScales[designObject.itemId] = Vector3(
        designObject.scale.x,
        designObject.scale.y,
        designObject.scale.z,
      );
    }
  }

  // Callback when AR view is created and ready
  void _onARViewCreated(ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,) {
    _arSessionManager = sessionManager;
    _arObjectManager = objectManager;
    _arAnchorManager = anchorManager;

    // Initialize AR session with configuration
    _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      showAnimatedGuide: false,
    );

    _arObjectManager!.onInitialize();

    // Handle object selection when user taps on AR objects
    _arObjectManager!.onNodeTap = (nodeName) {
      setState(() {
        _selectedObjectId = nodeName as String?;
      });
      print('Object tapped: $nodeName');
    };

    setState(() {
      _arInitialized = true;
    });

    // Load design objects into AR scene once AR is initialized
    if (_selectedDesign != null) {
      _placeDesignObjectsInAR();
    }
  }

  // Place all design objects in the AR scene
  Future<void> _placeDesignObjectsInAR() async {
    if (_selectedDesign == null || _arObjectManager == null) return;

    print('Placing ${_selectedDesign!.objects.length} objects in AR');

    // Clear existing nodes
    for (final node in _arNodes) {
      await _arObjectManager!.removeNode(node);
    }
    _arNodes.clear();

    // Place each design object in AR with saved transformations
    for (final designObject in _selectedDesign!.objects) {
      await _placeDesignObject(designObject);
    }
  }

  // Place individual design object in AR scene
  Future<void> _placeDesignObject(DesignObject designObject) async {
    if (_arObjectManager == null) return;

    try {
      // Get furniture item details for AR model
      final cameraViewModel = Provider.of<CameraViewModel>(
          context, listen: false);
      final furnitureItem = await _getFurnitureItem(
          designObject.itemId, cameraViewModel);

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      if (furnitureItem != null && furnitureItem.arModelUrl != null) {
        modelUrl = _cloudinaryService.getArModelUrl(furnitureItem.arModelUrl!);
        print('Using AR model: $modelUrl');
      } else {
        print('Using default model for item: ${designObject.itemId}');
      }

      // Use saved transformations or design object values
      final position = _objectPositions[designObject.itemId] ??
          Vector3(designObject.position.x, designObject.position.y,
              designObject.position.z);

      final rotation = _objectRotations[designObject.itemId] ??
          designObject.rotation.y;

      final scale = _objectScales[designObject.itemId] ??
          Vector3(
              designObject.scale.x, designObject.scale.y, designObject.scale.z);

      // Create AR node with transformation data
      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: scale,
        position: position,
        rotation: Vector4(0, 1, 0, rotation),
        name: designObject.itemId,
      );

      // Add node to AR scene
      final bool? didAdd = await _arObjectManager!.addNode(node);
      if (didAdd == true) {
        _arNodes.add(node);
        print('Placed object in AR: ${designObject
            .itemId} at position: $position');
      } else {
        print('Failed to place object: ${designObject.itemId}');
      }
    } catch (e) {
      print('Error placing design object in AR: $e');
    }
  }

  // Get furniture item details from viewmodel
  Future<FurnitureItem?> _getFurnitureItem(String itemId,
      CameraViewModel cameraViewModel) async {
    try {
      await cameraViewModel.loadFurnitureItems();
      return cameraViewModel.availableFurnitureItems.firstWhere(
            (item) => item.id == itemId,
      );
    } catch (e) {
      print('Error getting furniture item: $e');
      return null;
    }
  }

  // Movement methods for manipulating objects in AR

  // Move selected object (or first object if none selected)
  Future<void> _moveSelectedOrFirstObject(double deltaX, double deltaY,
      double deltaZ) async {
    if (_selectedDesign == null || _selectedDesign!.objects.isEmpty) return;

    final String objectId = _selectedObjectId ??
        _selectedDesign!.objects.first.itemId;

    // Update local position
    final currentPosition = _objectPositions[objectId] ?? Vector3.zero();
    final newPosition = Vector3(
      currentPosition.x + deltaX,
      currentPosition.y + deltaY,
      currentPosition.z + deltaZ,
    );

    _objectPositions[objectId] = newPosition;

    // Update in AR scene
    await _updateObjectInAR(objectId);

    // Save to Firestore
    await _saveObjectTransformations(objectId);
  }

  // Rotate selected object
  Future<void> _rotateSelectedOrFirstObject(double deltaAngle) async {
    if (_selectedDesign == null || _selectedDesign!.objects.isEmpty) return;

    final String objectId = _selectedObjectId ??
        _selectedDesign!.objects.first.itemId;

    // Update local rotation
    final currentRotation = _objectRotations[objectId] ?? 0.0;
    final newRotation = currentRotation + deltaAngle;

    _objectRotations[objectId] = newRotation;

    // Update in AR scene
    await _updateObjectInAR(objectId);

    // Save to Firestore
    await _saveObjectTransformations(objectId);
  }

  // Scale selected object
  Future<void> _scaleSelectedOrFirstObject(double deltaScale) async {
    if (_selectedDesign == null || _selectedDesign!.objects.isEmpty) return;

    final String objectId = _selectedObjectId ??
        _selectedDesign!.objects.first.itemId;

    // Update local scale with limits to prevent extreme scaling
    final currentScale = _objectScales[objectId] ?? Vector3.all(1.0);
    final newScaleValue = (currentScale.x + deltaScale).clamp(0.1, 3.0);
    final newScale = Vector3.all(newScaleValue);

    _objectScales[objectId] = newScale;

    // Update in AR scene
    await _updateObjectInAR(objectId);

    // Save to Firestore
    await _saveObjectTransformations(objectId);
  }

  // Update object position/rotation/scale in AR scene
  Future<void> _updateObjectInAR(String objectId) async {
    if (_arObjectManager == null) return;

    try {
      // Find the AR node
      final nodeIndex = _arNodes.indexWhere((node) => node.name == objectId);
      if (nodeIndex == -1) return;

      final oldNode = _arNodes[nodeIndex];

      // Remove old node
      await _arObjectManager!.removeNode(oldNode);

      final position = _objectPositions[objectId] ?? oldNode.position;

      double rotationValue;
      if (_objectRotations.containsKey(objectId)) {
        rotationValue = _objectRotations[objectId]!;
      } else {
        if (oldNode.rotation is Vector4) {
          rotationValue = (oldNode.rotation as Vector4).w;
        } else {
          rotationValue = 0.0;
        }
      }

      final scale = _objectScales[objectId] ?? oldNode.scale;

      // Create new node with updated transformations
      final newNode = ARNode(
        type: oldNode.type,
        uri: oldNode.uri,
        scale: scale,
        position: position,
        rotation: Vector4(0, 1, 0, rotationValue),
        name: objectId,
      );

      // Add new node to AR scene
      final bool? didAdd = await _arObjectManager!.addNode(newNode);
      if (didAdd == true) {
        _arNodes[nodeIndex] = newNode;
        print('Updated object in AR: $objectId');
      }
    } catch (e) {
      print('Error updating object in AR: $e');
    }
  }

  // Save object transformations to Firestore
  Future<void> _saveObjectTransformations(String objectId) async {
    if (_selectedDesign == null) return;

    try {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

      final position = _objectPositions[objectId]!;
      final rotation = _objectRotations[objectId]!;
      final scale = _objectScales[objectId]!;

      await viewModel.updateProjectDesign(
        projectId: widget.projectId,
        designId: _selectedDesign!.id,
        itemId: objectId,
        position: Position(x: position.x, y: position.y, z: position.z),
        rotation: Rotation(x: 0, y: rotation, z: 0),
        scale: Scale(x: scale.x, y: scale.y, z: scale.z),
      );

      print('Saved transformations for object: $objectId');
    } catch (e) {
      print('Error saving transformations: $e');
    }
  }

  // Add new furniture object to the design
  Future<void> _addNewObject() async {
    if (_selectedDesign == null || _arObjectManager == null) return;

    final cameraViewModel = Provider.of<CameraViewModel>(
        context, listen: false);
    final roomieLabViewModel = Provider.of<RoomieLabViewModel>(
        context, listen: false);

    // Show furniture selector dialog
    final selectedFurniture = await _showFurnitureSelector(cameraViewModel);
    if (selectedFurniture == null) return;

    // Create new design object with default transformations
    final newObject = DesignObject(
      itemId: selectedFurniture.id,
      position: Position(x: 0, y: 0, z: -1.5),
      rotation: Rotation(x: 0, y: 0, z: 0),
      scale: Scale(x: 0.3, y: 0.3, z: 0.3),
    );

    // Add to design in Firestore
    final success = await roomieLabViewModel.addDesignObject(
      designId: _selectedDesign!.id,
      designObject: newObject,
    );

    if (success) {
      // Update local transformations
      _objectPositions[newObject.itemId] = Vector3(
        newObject.position.x,
        newObject.position.y,
        newObject.position.z,
      );
      _objectRotations[newObject.itemId] = newObject.rotation.y;
      _objectScales[newObject.itemId] = Vector3(
        newObject.scale.x,
        newObject.scale.y,
        newObject.scale.z,
      );

      // Place in AR scene
      await _placeDesignObject(newObject);
      // Refresh designs to get updated list
      await _loadProjectAndDesigns();
    }
  }

  // Show furniture selection dialog
  Future<FurnitureItem?> _showFurnitureSelector(
      CameraViewModel cameraViewModel) async {
    await cameraViewModel.loadFurnitureItems();

    return showDialog<FurnitureItem>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Select Furniture'),
            content: Container(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: cameraViewModel.availableFurnitureItems.length,
                itemBuilder: (context, index) {
                  final item = cameraViewModel.availableFurnitureItems[index];
                  return ListTile(
                    leading: item.imageUrl != null
                        ? Image.network(item.imageUrl!, width: 40, height: 40)
                        : Icon(Icons.chair),
                    title: Text(item.name),
                    subtitle: Text(item.roomType),
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // Remove selected object from design
  Future<void> _removeSelectedObject() async {
    if (_selectedObjectId == null || _selectedDesign == null) return;

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    final success = await viewModel.removeDesignObject(
      designId: _selectedDesign!.id,
      itemId: _selectedObjectId!,
    );

    if (success && mounted) {
      // Remove from AR scene
      final node = _arNodes.firstWhere((node) =>
      node.name == _selectedObjectId);
      await _arObjectManager?.removeNode(node);
      _arNodes.removeWhere((node) => node.name == _selectedObjectId);

      // Remove from local transformations
      _objectPositions.remove(_selectedObjectId);
      _objectRotations.remove(_selectedObjectId);
      _objectScales.remove(_selectedObjectId);

      setState(() {
        _selectedObjectId = null;
      });

      await _loadProjectAndDesigns();
    }
  }

  // Capture screenshot of AR scene
  Future<void> _captureScreenshot() async {
    if (_arSessionManager == null) {
      print('AR Session Manager is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AR not initialized')),
      );
      return;
    }

    setState(() {
      _isCapturingScreenshot = true;
    });

    try {
      print('Starting screenshot capture...');

      // Use the CameraViewModel to capture screenshot
      final cameraViewModel = Provider.of<CameraViewModel>(
          context, listen: false);

      if (cameraViewModel.arSessionManager == null &&
          _arSessionManager != null &&
          _arObjectManager != null &&
          _arAnchorManager != null) {
        cameraViewModel.onARViewCreated(
            _arSessionManager!,
            _arObjectManager!,
            _arAnchorManager!,
            ARLocationManager()
        );
      }

      await cameraViewModel.captureScreenshot();

      print('Screenshot capture completed');

      if (cameraViewModel.lastScreenshot != null && mounted) {
        _showScreenshotOptions(cameraViewModel);
      } else {
        print('Screenshot capture failed - no data');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to capture screenshot - no image data')),
          );
        }
      }
    } catch (e) {
      print('Error capturing screenshot: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing screenshot: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturingScreenshot = false;
        });
      }
    }
  }

  // Show dialog with screenshot options (save to RoomieLab or gallery)
  void _showScreenshotOptions(CameraViewModel cameraViewModel) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightPurple,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.photo_camera, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Screenshot Captured!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Image Preview
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery
                          .of(context)
                          .size
                          .height * 0.5,
                    ),
                    padding: EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        cameraViewModel.lastScreenshot!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Save to RoomieLab button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLightPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(Icons.workspace_premium),
                            label: Text(
                              'Save to RoomieLab',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await _saveToRoomieLab(cameraViewModel);
                            },
                          ),
                        ),

                        SizedBox(height: 12),

                        // Save to Gallery button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryLightPurple,
                              side: BorderSide(
                                  color: AppColors.primaryLightPurple,
                                  width: 2),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.photo_library),
                            label: Text(
                              'Save to Gallery',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await _saveToGallery(cameraViewModel);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Save screenshot to RoomieLab design
  Future<void> _saveToRoomieLab(CameraViewModel cameraViewModel) async {
    setState(() {
      _isCapturingScreenshot = true;
    });

    try {
      // Update design with new screenshot
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

      // Upload image to Cloudinary
      final imageFile = File(cameraViewModel.capturedImagePath!);
      final imageUrl = await _uploadImageToCloudinary(imageFile);

      // Update design metadata with new image
      final success = await viewModel.updateDesignMetadata(
        designId: _selectedDesign!.id,
        imageUrl: imageUrl,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Design updated with new screenshot!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Error updating design: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturingScreenshot = false;
        });
      }
    }
  }

  // Save screenshot to device gallery
  Future<void> _saveToGallery(CameraViewModel cameraViewModel) async {
    setState(() {
      _isCapturingScreenshot = true;
    });

    try {
      final success = await cameraViewModel.saveToGallery();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Screenshot saved to gallery!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to save to gallery: ${cameraViewModel.error}'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Error saving to gallery: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturingScreenshot = false;
        });
      }
    }
  }

  // Upload image to Cloudinary storage
  Future<String> _uploadImageToCloudinary(File imageFile) async {
    try {
      final designId = _selectedDesign?.id ?? 'design_${DateTime
          .now()
          .millisecondsSinceEpoch}';
      final imageUrl = await _cloudinaryService.uploadDesignImage(
          imageFile, designId);
      return imageUrl;
    } catch (e) {
      print('Cloudinary upload failed: $e');
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentProject?.name ?? 'Edit Project',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Screenshot button with loading indicator
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.photo_camera, color: Colors.white),
                onPressed: _isCapturingScreenshot ? null : _captureScreenshot,
                tooltip: 'Capture Screenshot',
              ),
              if (_isCapturingScreenshot)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: _buildFAB(),
    );
  }

  // Build main content based on state
  Widget _buildContent() {
    if (_designs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.design_services, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No designs found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createNewDesign,
              child: Text('Create First Design'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // AR View - main AR scene
        ARView(
          onARViewCreated: _onARViewCreated,
        ),

        // Design info banner
        if (_selectedDesign != null) _buildDesignInfoPanel(),

        // Object controls panel for movement/rotation/scale
        if (_selectedDesign != null && _selectedDesign!.objects.isNotEmpty)
          _buildObjectControlsPanel(),

        // Selected object indicator
        if (_selectedObjectId != null) _buildSelectedObjectIndicator(),

        // Loading overlay for AR initialization
        if (!_arInitialized)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                  SizedBox(height: 16),
                  Text(
                    'Initializing AR...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

        // Screenshot capture overlay
        if (_isCapturingScreenshot)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                  SizedBox(height: 16),
                  Text(
                    'Capturing Screenshot...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Design information panel showing current design details
  Widget _buildDesignInfoPanel() {
    return Positioned(
      top: MediaQuery
          .of(context)
          .padding
          .top + 60,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.design_services,
                color: AppColors.primaryLightPurple,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDesign!.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${_selectedDesign!.objects.length} objects placed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedDesign!.objects.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Object controls panel for movement, rotation and scaling
  Widget _buildObjectControlsPanel() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedObjectId != null ? 'Moving Selected' : 'Object Controls',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),

            // Movement controls
            _buildMovementControls(),

            SizedBox(height: 8),

            // Rotation and Scale controls
            _buildRotationScaleControls(),

            SizedBox(height: 4),

            // Selection hint
            if (_selectedObjectId == null)
              Text(
                'Tap object to select',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // Movement controls with directional buttons
  Widget _buildMovementControls() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Move',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _buildDirectionalButton(
                    icon: Icons.arrow_upward,
                    onPressed: () => _moveSelectedOrFirstObject(0, 0, -0.1),
                    size: 16,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      _buildDirectionalButton(
                        icon: Icons.arrow_back,
                        onPressed: () => _moveSelectedOrFirstObject(-0.1, 0, 0),
                        size: 16,
                      ),
                      SizedBox(width: 40),
                      _buildDirectionalButton(
                        icon: Icons.arrow_forward,
                        onPressed: () => _moveSelectedOrFirstObject(0.1, 0, 0),
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  _buildDirectionalButton(
                    icon: Icons.arrow_downward,
                    onPressed: () => _moveSelectedOrFirstObject(0, 0, 0.1),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Rotation and scale controls
  Widget _buildRotationScaleControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Rotation controls
        Column(
          children: [
            Text('Rotate', style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )),
            SizedBox(height: 2),
            Row(
              children: [
                _buildControlButton(
                  icon: Icons.rotate_left,
                  onPressed: () => _rotateSelectedOrFirstObject(-0.5),
                  tooltip: 'Rotate Left',
                  size: 16,
                ),
                SizedBox(width: 6),
                _buildControlButton(
                  icon: Icons.rotate_right,
                  onPressed: () => _rotateSelectedOrFirstObject(0.5),
                  tooltip: 'Rotate Right',
                  size: 16,
                ),
              ],
            ),
          ],
        ),

        // Scale controls
        Column(
          children: [
            Text('Scale', style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )),
            SizedBox(height: 2),
            Row(
              children: [
                _buildControlButton(
                  icon: Icons.zoom_out,
                  onPressed: () => _scaleSelectedOrFirstObject(-0.1),
                  tooltip: 'Scale Down',
                  size: 16,
                ),
                SizedBox(width: 6),
                _buildControlButton(
                  icon: Icons.zoom_in,
                  onPressed: () => _scaleSelectedOrFirstObject(0.1),
                  tooltip: 'Scale Up',
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Directional button for movement controls
  Widget _buildDirectionalButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 20,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryLightPurple,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        iconSize: size,
        onPressed: onPressed,
        padding: EdgeInsets.all(4),
      ),
    );
  }

  // Control button for rotation and scaling
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    double size = 20,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryLightPurple,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, size: size, color: Colors.white),
          onPressed: onPressed,
          padding: EdgeInsets.all(6),
        ),
      ),
    );
  }

  // Selected object indicator with remove option
  Widget _buildSelectedObjectIndicator() {
    return Positioned(
      bottom: 200,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Object Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(Icons.delete, size: 16),
              label: Text(
                'Remove',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: _removeSelectedObject,
            ),
          ],
        ),
      ),
    );
  }

  // Floating Action Buttons for adding objects and switching designs
  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'add_object',
          onPressed: _addNewObject,
          backgroundColor: AppColors.primaryLightPurple,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          tooltip: 'Add Furniture',
        ),
        SizedBox(height: 16),

        if (_designs.length > 1)
          FloatingActionButton(
            heroTag: 'design_selector',
            onPressed: _showDesignSelector,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryLightPurple,
            child: Icon(Icons.design_services),
            tooltip: 'Switch Design',
          ),
      ],
    );
  }

  // Show design selector dialog
  Future<void> _showDesignSelector() async {
    final selectedDesign = await showDialog<Design>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Select Design'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: _designs.length,
                itemBuilder: (context, index) {
                  final design = _designs[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.design_services,
                        color: AppColors.primaryLightPurple,
                      ),
                    ),
                    title: Text(design.name),
                    subtitle: Text('${design.objects.length} objects'),
                    trailing: _selectedDesign?.id == design.id
                        ? Icon(Icons.check, color: AppColors.primaryLightPurple)
                        : null,
                    onTap: () => Navigator.pop(context, design),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
    );

    if (selectedDesign != null && selectedDesign.id != _selectedDesign?.id) {
      setState(() {
        _selectedDesign = selectedDesign;
        _selectedObjectId = null;
      });
      _initializeObjectTransformations();
      _placeDesignObjectsInAR();
    }
  }

  // Create new design for the project
  Future<void> _createNewDesign() async {
    try {
      final designName = await _showDesignNameDialog();
      if (designName == null || designName.isEmpty) return;

      final designId = await _designService.createDesign(
        name: designName,
        projectId: widget.projectId,
        objects: [],
      );

      final newDesign = Design(
        id: designId,
        userId: '',
        projectId: widget.projectId,
        name: designName,
        objects: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastViewed: DateTime.now(),
      );

      setState(() {
        _selectedDesign = newDesign;
        _designs.add(newDesign);
      });

      _initializeObjectTransformations();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New design "$designName" created!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating design: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show dialog for entering new design name
  Future<String?> _showDesignNameDialog() async {
    String designName = '';

    return showDialog<String>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Create New Design'),
            content: TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Design Name',
                hintText: 'e.g., Living Room Layout',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => designName = value,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (designName.isNotEmpty) {
                    Navigator.pop(context, designName);
                  }
                },
                child: Text('Create'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _arSessionManager?.dispose();
    super.dispose();
  }
}
