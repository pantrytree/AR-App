import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Roomantics/viewmodels/camera_viewmodel.dart';
import 'package:Roomantics/models/furniture_item.dart';

import '../../models/design_object.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  String _designName = 'My AR Design';

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
      viewModel.disposeCamera();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Camera Preview - Full screen
              Positioned.fill(
                child: _buildCameraPreview(viewModel),
              ),

              // Object placement overlay (simulated AR objects)
              if (viewModel.hasPlacedObjects) _buildObjectOverlay(viewModel),

              // Top App Bar
              _buildAppBar(viewModel),

              // Bottom Controls
              _buildBottomControls(viewModel),

              // Furniture Selection Panel
              if (viewModel.isFurnitureSelectionVisible)
                _buildFurnitureSelection(viewModel),

              // Loading Overlay
              if (viewModel.isLoading) _buildLoadingOverlay(),

              // Error Overlay
              if (viewModel.error != null) _buildErrorOverlay(viewModel),
            ],
          );
        },
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

    return GestureDetector(
      onTapDown: (details) {
        // Place object where user taps
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        viewModel.placeObject(localPosition);
      },
      child: CameraPreview(viewModel.controller!),
    );
  }

  Widget _buildObjectOverlay(CameraViewModel viewModel) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ObjectOverlayPainter(viewModel.placedObjects),
        ),
      ),
    );
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
          if (viewModel.hasPlacedObjects)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: viewModel.clearAllObjects,
              tooltip: 'Clear All Objects',
            ),
          IconButton(
            icon: Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: viewModel.switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(CameraViewModel viewModel) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Delete Button
            _buildControlButton(
              icon: Icons.delete,
              label: 'Delete',
              onPressed: viewModel.removeLastObject,
              isActive: viewModel.hasPlacedObjects,
            ),

            // Add Furniture Button
            _buildControlButton(
              icon: Icons.add,
              label: 'Add',
              onPressed: viewModel.toggleFurnitureSelection,
              isActive: true,
            ),

            // Capture Button (Center)
            _buildCaptureButton(viewModel),

            // Switch Camera Button
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              label: 'Switch',
              onPressed: viewModel.switchCamera,
              isActive: true,
            ),

            // Info Button
            _buildControlButton(
              icon: Icons.help_outline,
              label: 'Help',
              onPressed: _showHelpDialog,
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: isActive ? Colors.white : Colors.white54),
          onPressed: isActive ? onPressed : null,
          iconSize: 28,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton(CameraViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _captureImage(viewModel),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.transparent,
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Capture',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFurnitureSelection(CameraViewModel viewModel) {
    return Positioned(
      bottom: 140, // Position above bottom controls
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                'Select Furniture:',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.availableFurnitureItems.length,
                itemBuilder: (context, index) {
                  final furniture = viewModel.availableFurnitureItems[index];
                  return _buildFurnitureItem(furniture, viewModel);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFurnitureItem(FurnitureItem furniture, CameraViewModel viewModel) {
    final isSelected = viewModel.selectedFurnitureItem?.id == furniture.id;

    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => viewModel.selectFurnitureItem(furniture),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFurnitureIcon(furniture.category),
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                furniture.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
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

  Future<void> _captureImage(CameraViewModel viewModel) async {
    await viewModel.captureImage();

    if (viewModel.capturedImagePath != null) {
      _showSaveDialog(viewModel);
    }
  }

  void _showSaveDialog(CameraViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Save to RoomieLab',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (viewModel.capturedImagePath != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(viewModel.capturedImagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Text(
                'Save this AR design to RoomieLab?',
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 8),
              Text(
                'Objects placed: ${viewModel.placedObjects.length}',
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Design Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _designName = value.isNotEmpty ? value : 'My AR Design';
                  });
                },
              ),
            ],
          ),
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
              final success = await viewModel.saveDesignToRoomieLab(_designName);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Design saved successfully to RoomieLab!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save design: ${viewModel.error}'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text('Save to RoomieLab', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AR Camera Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('Add Furniture', 'Tap the Add button to select furniture, then tap on screen to place it'),
              _buildHelpItem('Place Objects', 'Tap anywhere on the screen to place the selected furniture'),
              _buildHelpItem('Delete Objects', 'Use Delete button to remove the last placed object'),
              _buildHelpItem('Clear All', 'Use the clear button in top bar to remove all objects'),
              _buildHelpItem('Capture', 'Take a photo of your AR design and save to RoomieLab'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// Custom painter to simulate AR object overlay
class ObjectOverlayPainter extends CustomPainter {
  final List<DesignObject> objects;

  ObjectOverlayPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final obj in objects) {
      final center = Offset(obj.position.x, obj.position.y);
      final radius = 20.0 * obj.scale.x;

      // Draw circle representing the object
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(center, radius, borderPaint);

      // Draw a simple icon in the center
      final textPainter = TextPainter(
        text: TextSpan(
          text: '📦', // Placeholder icon
          style: TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}