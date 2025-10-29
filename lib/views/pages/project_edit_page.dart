import 'package:Roomantics/services/cloudinary_service.dart';
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

import '/viewmodels/roomielab_viewmodel.dart';
import '/viewmodels/camera_viewmodel.dart';
import '/models/design.dart';
import '/models/design_object.dart';
import '/models/furniture_item.dart';

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
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  CloudinaryService _cloudinaryService = CloudinaryService();
  List<Design> _designs = [];
  Design? _selectedDesign;
  List<ARNode> _arNodes = [];
  bool _isLoading = true;
  bool _arInitialized = false;
  String? _selectedObjectId;
  bool _isCapturingScreenshot = false;

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  Future<void> _loadDesigns() async {
    try {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      _designs = await viewModel.getProjectDesigns(widget.projectId);

      if (_designs.isNotEmpty) {
        _selectedDesign = widget.initialDesignId != null
            ? _designs.firstWhere(
              (design) => design.id == widget.initialDesignId,
          orElse: () => _designs.first,
        )
            : _designs.first;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading designs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    _arSessionManager = sessionManager;
    _arObjectManager = objectManager;
    _arAnchorManager = anchorManager;

    _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
      showAnimatedGuide: false, // Remove hand guide
    );

    _arObjectManager!.onInitialize();

    _arObjectManager!.onNodeTap = (nodeName) {
      setState(() {
        _selectedObjectId = nodeName as String?;
      });
      print('Object tapped: $nodeName');
    };

    setState(() {
      _arInitialized = true;
    });

    // Load design objects into AR scene
    if (_selectedDesign != null) {
      _placeDesignObjectsInAR();
    }
  }

  Future<void> _placeDesignObjectsInAR() async {
    if (_selectedDesign == null || _arObjectManager == null) return;

    print('Placing ${_selectedDesign!.objects.length} objects in AR');

    // Clear existing nodes
    for (final node in _arNodes) {
      await _arObjectManager!.removeNode(node);
    }
    _arNodes.clear();

    // Place each design object in AR
    for (final designObject in _selectedDesign!.objects) {
      await _placeDesignObject(designObject);
    }
  }

  Future<void> _placeDesignObject(DesignObject designObject) async {
    if (_arObjectManager == null) return;

    try {
      // Get furniture item details
      final cameraViewModel = Provider.of<CameraViewModel>(context, listen: false);
      final furnitureItem = await _getFurnitureItem(designObject.itemId, cameraViewModel);

      String modelUrl = "https://modelviewer.dev/shared-assets/models/Astronaut.glb";
      if (furnitureItem != null && furnitureItem.arModelUrl != null) {
        modelUrl = _cloudinaryService.getArModelUrl(furnitureItem.arModelUrl!);
        print('Using AR model: $modelUrl');
      } else {
        print('Using default model for item: ${designObject.itemId}');
      }

      // Create AR node from design object
      final node = ARNode(
        type: NodeType.webGLB,
        uri: modelUrl,
        scale: Vector3(
          designObject.scale.x,
          designObject.scale.y,
          designObject.scale.z,
        ),
        position: Vector3(
          designObject.position.x,
          designObject.position.y,
          designObject.position.z,
        ),
        rotation: Vector4(
          0, 1, 0, designObject.rotation.y,
        ),
        name: designObject.itemId,
      );

      final bool? didAdd = await _arObjectManager!.addNode(node);
      if (didAdd == true) {
        _arNodes.add(node);
        print('✓ Placed object in AR: ${designObject.itemId} at position: ${designObject.position}');
      } else {
        print('✗ Failed to place object: ${designObject.itemId}');
      }
    } catch (e) {
      print('Error placing design object in AR: $e');
    }
  }

  Future<FurnitureItem?> _getFurnitureItem(String itemId, CameraViewModel cameraViewModel) async {
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

  Future<void> _addNewObject() async {
    if (_selectedDesign == null || _arObjectManager == null) return;

    final cameraViewModel = Provider.of<CameraViewModel>(context, listen: false);
    final roomieLabViewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

    // Show furniture selector
    final selectedFurniture = await _showFurnitureSelector(cameraViewModel);
    if (selectedFurniture == null) return;

    // Create new design object
    final newObject = DesignObject(
      itemId: selectedFurniture.id,
      position: Position(x: 0, y: 0, z: -1.5),
      rotation: Rotation(x: 0, y: 0, z: 0),
      scale: Scale(x: 0.3, y: 0.3, z: 0.3),
    );

    // Add to design
    final success = await roomieLabViewModel.addDesignObject(
      designId: _selectedDesign!.id,
      designObject: newObject,
    );

    if (success) {
      // Place in AR scene
      await _placeDesignObject(newObject);
      // Refresh designs
      await _loadDesigns();
    }
  }

  Future<FurnitureItem?> _showFurnitureSelector(CameraViewModel cameraViewModel) async {
    await cameraViewModel.loadFurnitureItems();

    return showDialog<FurnitureItem>(
      context: context,
      builder: (context) => AlertDialog(
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

  Future<void> _createNewDesign() async {
    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    final designId = await viewModel.createDesign(
      projectId: widget.projectId,
      name: 'New Design ${_designs.length + 1}',
      objects: [],
    );

    if (designId != null && mounted) {
      await _loadDesigns();
    }
  }

  Future<void> _updateObjectPosition(String itemId, Position newPosition) async {
    if (_selectedDesign == null) return;

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

    // Find the object
    final object = _selectedDesign!.objects.firstWhere(
          (obj) => obj.itemId == itemId,
    );

    // Update position
    final updatedObject = object.copyWith(position: newPosition);

    await viewModel.updateProjectDesign(
      projectId: widget.projectId,
      designId: _selectedDesign!.id,
      itemId: itemId,
      position: newPosition,
      rotation: updatedObject.rotation,
      scale: updatedObject.scale,
    );

    // Refresh AR scene
    await _placeDesignObjectsInAR();
  }

  Future<void> _removeSelectedObject() async {
    if (_selectedObjectId == null || _selectedDesign == null) return;

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    final success = await viewModel.removeDesignObject(
      designId: _selectedDesign!.id,
      itemId: _selectedObjectId!,
    );

    if (success && mounted) {
      // Remove from AR scene
      final node = _arNodes.firstWhere((node) => node.name == _selectedObjectId);
      await _arObjectManager?.removeNode(node);
      _arNodes.removeWhere((node) => node.name == _selectedObjectId);

      setState(() {
        _selectedObjectId = null;
      });

      await _loadDesigns();
    }
  }

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
      final cameraViewModel = Provider.of<CameraViewModel>(context, listen: false);

      // Initialize AR session in camera viewmodel if needed
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
      print('Captured image path: ${cameraViewModel.capturedImagePath}');
      print('Last screenshot data: ${cameraViewModel.lastScreenshot != null ? "${cameraViewModel.lastScreenshot!.length} bytes" : "null"}');

      if (cameraViewModel.lastScreenshot != null && mounted) {
        _showScreenshotOptions(cameraViewModel);
      } else {
        print('Screenshot capture failed - no data');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to capture screenshot - no image data')),
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

  void _showScreenshotOptions(CameraViewModel cameraViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.photo_camera, color: AppColors.primaryPurple),
            SizedBox(width: 8),
            Text('Screenshot Captured!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What would you like to do with the screenshot?'),
            SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  image: MemoryImage(cameraViewModel.lastScreenshot!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveToGallery(cameraViewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: Text('Save to Gallery'),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          // Design selector
          if (_designs.isNotEmpty) _buildDesignSelector(),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.photo_camera),
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
      floatingActionButton: _buildSimplifiedFAB(),
    );
  }

  Widget _buildDesignSelector() {
    return PopupMenuButton<Design>(
      icon: Icon(Icons.design_services),
      onSelected: (Design design) async {
        setState(() {
          _selectedDesign = design;
          _selectedObjectId = null;
        });
        await _placeDesignObjectsInAR();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text('New Design'),
            ],
          ),
        ),
        PopupMenuDivider(),
        ..._designs.map((design) => PopupMenuItem(
          value: design,
          child: Row(
            children: [
              Icon(Icons.photo_library, size: 20),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${design.objects.length} objects',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

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
        // AR View
        ARView(
          onARViewCreated: _onARViewCreated,
        ),

        // Design Info Panel - ALWAYS VISIBLE
        if (_selectedDesign != null) _buildDesignInfoPanel(),

        // Object Controls Panel - ALWAYS VISIBLE when objects exist
        if (_selectedDesign != null && _selectedDesign!.objects.isNotEmpty)
          _buildObjectControlsPanel(),

        // Selected Object Controls - Only for selected objects
        if (_selectedObjectId != null) _buildSelectedObjectControls(),

        // Loading overlay for AR
        if (!_arInitialized)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
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
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
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

  Widget _buildDesignInfoPanel() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        width: 280,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.design_services, color: AppColors.primaryPurple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDesign!.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Objects: ${_selectedDesign!.objects.length}'),
            SizedBox(height: 8),
            if (_selectedObjectId != null) ...[
              Divider(),
              Text(
                'Selected Object:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                'ID: ${_selectedObjectId!.substring(0, 8)}...',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _removeSelectedObject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 36),
                ),
                child: Text('Remove Object'),
              ),
            ] else if (_selectedDesign!.objects.isNotEmpty) ...[
              Divider(),
              Text(
                'Tap on any object to select it',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // NEW: Always visible object controls panel
  Widget _buildObjectControlsPanel() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
            Text(
              _selectedObjectId != null ? 'Move Selected Object' : 'Object Controls',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Movement controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Forward/Backward
                Column(
                  children: [
                    Text('Forward/Back', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildControlButton(
                          icon: Icons.arrow_upward,
                          onPressed: () => _moveSelectedOrFirstObject(0, 0, -0.1),
                          tooltip: 'Move Forward',
                        ),
                        SizedBox(width: 8),
                        _buildControlButton(
                          icon: Icons.arrow_downward,
                          onPressed: () => _moveSelectedOrFirstObject(0, 0, 0.1),
                          tooltip: 'Move Backward',
                        ),
                      ],
                    ),
                  ],
                ),

                // Left/Right
                Column(
                  children: [
                    Text('Left/Right', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildControlButton(
                          icon: Icons.arrow_back,
                          onPressed: () => _moveSelectedOrFirstObject(-0.1, 0, 0),
                          tooltip: 'Move Left',
                        ),
                        SizedBox(width: 8),
                        _buildControlButton(
                          icon: Icons.arrow_forward,
                          onPressed: () => _moveSelectedOrFirstObject(0.1, 0, 0),
                          tooltip: 'Move Right',
                        ),
                      ],
                    ),
                  ],
                ),

                // Rotate
                Column(
                  children: [
                    Text('Rotate', style: TextStyle(fontSize: 10)),
                    SizedBox(height: 4),
                    _buildControlButton(
                      icon: Icons.rotate_right,
                      onPressed: _rotateSelectedOrFirstObject,
                      tooltip: 'Rotate Object',
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 8),

            // Selection hint
            if (_selectedObjectId == null && _selectedDesign!.objects.isNotEmpty)
              Text(
                'Tip: Tap on any object to select it for movement',
                style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, size: 20, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildSelectedObjectControls() {
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
            Text(
              'Selected',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 4),
            Text(
              'Object',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for object movement
  void _moveSelectedOrFirstObject(double deltaX, double deltaY, double deltaZ) {
    if (_selectedDesign == null || _selectedDesign!.objects.isEmpty) return;

    final String objectId = _selectedObjectId ?? _selectedDesign!.objects.first.itemId;
    final object = _selectedDesign!.objects.firstWhere((obj) => obj.itemId == objectId);

    final newPosition = Position(
      x: object.position.x + deltaX,
      y: object.position.y + deltaY,
      z: object.position.z + deltaZ,
    );

    _updateObjectPosition(objectId, newPosition);
  }

  void _rotateSelectedOrFirstObject() {
    if (_selectedDesign == null || _selectedDesign!.objects.isEmpty) return;

    final String objectId = _selectedObjectId ?? _selectedDesign!.objects.first.itemId;
    final object = _selectedDesign!.objects.firstWhere((obj) => obj.itemId == objectId);

    final newRotation = Rotation(
      x: object.rotation.x,
      y: object.rotation.y + 0.5,
      z: object.rotation.z,
    );

    _updateObjectRotation(objectId, newRotation);
  }

  Future<void> _updateObjectRotation(String itemId, Rotation newRotation) async {
    if (_selectedDesign == null) return;

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

    final object = _selectedDesign!.objects.firstWhere(
          (obj) => obj.itemId == itemId,
    );

    await viewModel.updateProjectDesign(
      projectId: widget.projectId,
      designId: _selectedDesign!.id,
      itemId: itemId,
      position: object.position,
      rotation: newRotation,
      scale: object.scale,
    );

    await _placeDesignObjectsInAR();
  }

  Widget _buildSimplifiedFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add Object Button
        FloatingActionButton(
          heroTag: 'add_object',
          onPressed: _addNewObject,
          child: Icon(Icons.add),
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
        ),
        SizedBox(height: 16),

        // Reset Scene Button
        FloatingActionButton(
          heroTag: 'reset_scene',
          onPressed: _placeDesignObjectsInAR,
          child: Icon(Icons.refresh),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _arSessionManager?.dispose();
    super.dispose();
  }
}
