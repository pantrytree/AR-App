import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/viewmodels/camera_viewmodel.dart';
import 'package:Roomantics/models/furniture_item.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final viewModel = Provider.of<CameraViewModel>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      viewModel.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _initializeCamera() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CameraViewModel>(context, listen: false);
      viewModel.initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<CameraViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // Camera Preview
                _buildCameraPreview(viewModel),

                // Top App Bar
                _buildAppBar(viewModel),

                // Bottom Control Panel
                _buildBottomPanel(viewModel),

                // Loading Overlay
                if (viewModel.isLoading) _buildLoadingOverlay(),

                // Error Overlay
                if (viewModel.error != null) _buildErrorOverlay(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraViewModel viewModel) {
    if (viewModel.controller == null || !viewModel.isCameraReady) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(viewModel.controller!);
  }

  Widget _buildAppBar(CameraViewModel viewModel) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AR Camera',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (viewModel.isObjectPlaced)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: viewModel.clearAllObjects,
              tooltip: 'Clear All Objects',
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(CameraViewModel viewModel) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Furniture Selection Row
            if (viewModel.isFurnitureSelectionVisible)
              Container(
                height: 60, // Reduced height
                padding: EdgeInsets.symmetric(vertical: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.availableFurnitureItems.length,
                  itemBuilder: (context, index) {
                    final furniture = viewModel.availableFurnitureItems[index];
                    return _buildFurnitureItem(furniture, viewModel);
                  },
                ),
              ),

            // Main Control Buttons - Use Expanded with fixed constraints
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 40, // Ensure minimum height
                  maxHeight: 60, // Prevent excessive height
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Delete Button
                    _buildControlButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      onTap: viewModel.removeObject,
                      isActive: viewModel.isObjectPlaced,
                    ),

                    // Plus/Add Furniture Button
                    _buildControlButton(
                      icon: Icons.add,
                      label: 'Add',
                      onTap: () => viewModel.toggleFurnitureSelection(),
                      isActive: true,
                    ),

                    // Capture Button
                    _buildCaptureButton(viewModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFurnitureSelection(CameraViewModel viewModel) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.availableFurnitureItems.length,
        itemBuilder: (context, index) {
          final furniture = viewModel.availableFurnitureItems[index];
          return _buildFurnitureItem(furniture, viewModel);
        },
      ),
    );
  }

  Widget _buildFurnitureItem(FurnitureItem furniture, CameraViewModel viewModel) {
    final isSelected = viewModel.selectedFurnitureItem?.id == furniture.id;

    return SizedBox(
      width: 50, // Smaller width
      height: 50, // Fixed height
      child: GestureDetector(
        onTap: () {
          viewModel.selectFurnitureItem(furniture);
          viewModel.hideFurnitureSelection();
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFurnitureIcon(furniture.category),
                color: isSelected ? Colors.white : Colors.grey,
                size: 16, // Smaller icon
              ),
              SizedBox(height: 1),
              Text(
                furniture.name.length > 4
                    ? '${furniture.name.substring(0, 4)}..'
                    : furniture.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 7, // Very small font
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFurnitureIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sofa':
      case 'couch':
        return Icons.weekend;
      case 'chair':
        return Icons.chair;
      case 'table':
        return Icons.table_restaurant;
      case 'bed':
        return Icons.bed;
      case 'lamp':
      case 'lighting':
        return Icons.lightbulb;
      case 'storage':
        return Icons.shelves;
      default:
        return Icons.architecture;
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return SizedBox(
      height: 38, // Reduced from 50
      width: 45,  // Reduced from 50
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 24, // Reduced from 32
            width: 24,  // Reduced from 32
            child: IconButton(
              icon: Icon(icon),
              color: isActive ? Colors.white : Colors.grey,
              onPressed: isActive ? onTap : null,
              iconSize: 16, // Reduced from 20
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact, // Add this for extra compactness
            ),
          ),
          SizedBox(height: 0), // Remove spacing completely
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 7,  // Reduced from 8
              height: 0.8,  // Reduced line height
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton(CameraViewModel viewModel) {
    return SizedBox(
      height: 38, // Fixed height to match other buttons
      width: 50, // Slightly wider for capture button
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _captureImage(viewModel),
            child: Container(
              width: 32, // Smaller capture button
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.transparent,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 14, // Smaller icon
              ),
            ),
          ),
          SizedBox(height: 0), // Minimal spacing
          Text(
            'Capture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 7, // Very small font
              height: 0.8,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Processing...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(CameraViewModel viewModel) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Camera Error',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                viewModel.error!,
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: viewModel.initializeCamera,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureImage(CameraViewModel viewModel) async {
    await viewModel.captureImage(context);

    if (viewModel.hasCapturedImage) {
      _showPreviewDialog(viewModel);
    }
  }

  void _showPreviewDialog(CameraViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Design Preview',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (viewModel.capturedImagePath != null)
              Image.file(
                File(viewModel.capturedImagePath!),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            Text(
              'Save this design to RoomieLab?',
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 8),
            Text(
              'Objects placed: ${viewModel.placedObjects.length}',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.resetCapture();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.saveProjectToRoomieLab(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Design saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Go back to previous screen
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save design: ${viewModel.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}