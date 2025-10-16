import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../models/roomielab_model.dart';
import '/models/furniture_model.dart';
import '/services/furniture_service.dart';
import '/services/roomielab_service.dart';
import '/utils/colors.dart';
import 'furniture_catalogue_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isFurnitureSelectorOpen = false;
  List<FurnitureItem> _availableFurniture = [];
  List<FurnitureItem> _filteredFurniture = [];
  String _selectedCategory = 'All';
  final List<PlacedFurniture> _placedFurniture = [];
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadFurniture();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      await _cameraController.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _loadFurniture() {
    _availableFurniture = FurnitureService.allFurniture;
    _filteredFurniture = _availableFurniture;
  }

  void _filterFurniture(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredFurniture = _availableFurniture;
      } else {
        _filteredFurniture = _availableFurniture
            .where((item) => item.furnitureType.toLowerCase() == category.toLowerCase())
            .toList();
      }
    });
  }

  void _addFurnitureToScene(FurnitureItem furniture) {
    setState(() {
      _placedFurniture.add(PlacedFurniture(
        furnitureId: furniture.id,
        furnitureName: furniture.name,
        furnitureType: furniture.furnitureType,
        imageUrl: '', // You'll use the 3D model URL here
        position: Position(x: 0, y: 0, z: 0),
      ));
    });
    _toggleFurnitureSelector();
  }

  void _toggleFurnitureSelector() {
    setState(() {
      _isFurnitureSelectorOpen = !_isFurnitureSelectorOpen;
    });
  }

  Future<void> _captureDesign() async {
    try {
      if (!_isCameraInitialized) {
        print('Camera not initialized');
        return;
      }

      print('Taking picture...');
      final image = await _cameraController.takePicture();
      print('Picture taken: ${image.path}');

      setState(() {
        _capturedImage = image;
      });

      // Show save dialog with the captured image
      await _showSaveDesignDialog(image.path);

    } catch (e) {
      print('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSaveDesignDialog(String imagePath) async {
    final TextEditingController nameController = TextEditingController();

    // Auto-detect category from placed furniture
    String? detectedCategory;
    if (_placedFurniture.isNotEmpty) {
      detectedCategory = _placedFurniture.first.furnitureType;
    }

    bool? shouldDeleteImage = true; // Flag to track if we should delete the image

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Save Design',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview of captured image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Give your design a name',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'My Living Room Design',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (detectedCategory != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryLightPurple),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: AppColors.primaryLightPurple, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Category: $detectedCategory',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (detectedCategory == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No furniture selected. Design will be saved as "Uncategorized"',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Set flag to delete the image and close dialog
              shouldDeleteImage = true;
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                // Set flag to NOT delete the image (since we're saving it)
                shouldDeleteImage = false;
                Navigator.pop(context);
                await _saveDesign(
                    nameController.text,
                    imagePath,
                    detectedCategory ?? 'Uncategorized'
                );
              } else {
                // Show error if name is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a design name'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLightPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // After dialog closes, check if we should delete the temporary image
    if (shouldDeleteImage == true && _capturedImage != null) {
      print('Deleting temporary image: ${_capturedImage!.path}');
      try {
        final file = File(_capturedImage!.path);
        if (await file.exists()) {
          await file.delete();
          print('Temporary image deleted successfully');
        }
      } catch (e) {
        print('Error deleting temporary image: $e');
      }

      // Clear the captured image reference
      setState(() {
        _capturedImage = null;
      });
    }
  }

  Future<void> _saveDesign(String name, String imagePath, String category) async {
    try {
      print('Starting save process...');
      print('Design name: $name');
      print('Image path: $imagePath');
      print('Category: $category');

      final roomieLabService = RoomieLabService();

      // Save the image file
      print('Saving image...');
      final savedImagePath = await roomieLabService.saveImage(File(imagePath));
      print('Image saved to: $savedImagePath');

      final design = RoomieLabDesign(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        imagePath: savedImagePath,
        createdAt: DateTime.now(),
        placedFurniture: _placedFurniture,
        category: category,
      );

      print('Saving design to database...');
      await roomieLabService.saveDesign(design);
      print('Design saved successfully!');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Design "$name" saved in $category category!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear the scene after successful save
        _clearScene();
        setState(() {
          _capturedImage = null;
        });
      }
    } catch (e) {
      print('Error saving design: $e');
      // Handle any errors that occur during save
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving design: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _clearScene() {
    setState(() {
      _placedFurniture.clear();
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.getPrimaryColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // Furniture Selector Overlay
          if (_isFurnitureSelectorOpen)
            _buildFurnitureSelector(),

          // Control Buttons
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureSelector() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Furniture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: _toggleFurnitureSelector,
              ),
            ],
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                'All', 'Sofa', 'Chair', 'Table', 'Bed', 'Lamp'
              ].map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) => _filterFurniture(category),
                  ),
                );
              }).toList(),
            ),
          ),

          // Furniture Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredFurniture.length,
              itemBuilder: (context, index) {
                final furniture = _filteredFurniture[index];
                return GestureDetector(
                  onTap: () => _addFurnitureToScene(furniture),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightPurple,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Icon(
                              Icons.chair,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            furniture.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Furniture Selector Button
          _buildControlButton(
            icon: Icons.chair,
            label: 'Furniture',
            onTap: _toggleFurnitureSelector,
          ),

          // Capture Button
          _buildControlButton(
            icon: Icons.camera_alt,
            label: 'Capture',
            onTap: _captureDesign,
            isPrimary: true,
          ),

          // Clear Scene Button
          _buildControlButton(
            icon: Icons.clear,
            label: 'Clear',
            onTap: _clearScene,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryLightPurple : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: isPrimary ? Colors.white : Colors.white),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}