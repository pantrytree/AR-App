import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../models/design_object.dart' as design_models;
import '../../viewmodels/camera_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';
import '../../theme/theme.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraViewModel>().initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Consumer<CameraViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.hasCapturedImage) {
              return _buildPreviewState(viewModel, context);
            } else {
              return _buildLiveCameraState(viewModel, context);
            }
          },
        ),
      ),
    );
  }

  // ===========================================================
  // LIVE CAMERA STATE
  // ===========================================================
  Widget _buildLiveCameraState(CameraViewModel viewModel, BuildContext context) {
    return Stack(
      children: [
        _buildCameraPreview(viewModel, context),
        if (viewModel.isCameraReady) _buildARGridOverlay(),
        _buildTopControls(viewModel, context),
        _buildObjectPlacementControls(viewModel),

        // Bottom section: capture + selector
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCaptureButton(viewModel),
                const SizedBox(height: 10),
                _buildObjectSelector(viewModel),
              ],
            ),
          ),
        ),

        if (viewModel.isLoading) _buildLoadingOverlay(context),
        if (viewModel.error != null) _buildErrorMessage(viewModel, context),
      ],
    );
  }

  // ===========================================================
  // PREVIEW STATE (After capture)
  // ===========================================================
  Widget _buildPreviewState(CameraViewModel viewModel, BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(viewModel.capturedImagePath!), fit: BoxFit.cover),
        Container(color: Colors.black38),
        _buildTopControls(viewModel, context),

        // Object placement overlay in preview
        if (viewModel.placedObjects.isNotEmpty) _buildPlacedObjectsOverlay(),

        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => viewModel.resetCapture(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Retake"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _saveToRoomieLab(context, viewModel),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save to RoomieLab"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (viewModel.isLoading) _buildLoadingOverlay(context),
      ],
    );
  }

  Widget _buildObjectPlacementControls(CameraViewModel viewModel) {
    return Positioned(
      right: 20,
      top: 100,
      child: Column(
        children: [
          if (viewModel.isObjectPlaced)
            FloatingActionButton.small(
              onPressed: viewModel.removeObject,
              backgroundColor: Colors.red,
              child: const Icon(Icons.remove, color: Colors.white),
            ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            onPressed: () {
              // Place object at center of screen
              viewModel.placeObject(
                const Offset(0.5, 0.5), // Normalized coordinates
                1.0, // Scale
                0.0, // Rotation
              );
            },
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacedObjectsOverlay() {
    return Consumer<CameraViewModel>(
      builder: (context, viewModel, child) {
        return IgnorePointer(
          child: SizedBox.expand(
            child: CustomPaint(
              painter: _PlacedObjectsPainter(viewModel.placedObjects),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // CAMERA PREVIEW + PLACEHOLDER
  // ===========================================================
  Widget _buildCameraPreview(CameraViewModel viewModel, BuildContext context) {
    if (!viewModel.isCameraReady || viewModel.controller == null) {
      return _buildCameraPlaceholder(viewModel, context);
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(viewModel.controller!),
    );
  }

  Widget _buildCameraPlaceholder(CameraViewModel viewModel, BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (viewModel.isLoading)
              const CircularProgressIndicator(color: AppColors.white),
            const SizedBox(height: 20),
            Text(
              viewModel.isLoading ? 'Starting Camera...' : 'Camera Not Available',
              style: const TextStyle(color: AppColors.white, fontSize: 16),
            ),
            if (viewModel.error != null) ...[
              const SizedBox(height: 10),
              Text(
                viewModel.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // UI COMPONENTS
  // ===========================================================
  Widget _buildTopControls(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.camera, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  viewModel.isCameraReady ? 'Live Camera' : 'Setting Up...',
                  style: const TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (viewModel.isCameraReady)
            CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.cameraswitch, color: AppColors.white),
                onPressed: viewModel.switchCamera,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton(CameraViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.captureImage(context),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4),
          color: Colors.transparent,
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
          ),
          child: const Icon(Icons.camera_alt, color: AppColors.black, size: 28),
        ),
      ),
    );
  }

  Widget _buildObjectSelector(CameraViewModel viewModel) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.availableObjects.length,
        itemBuilder: (context, index) {
          final object = viewModel.availableObjects[index];
          final isSelected = object == viewModel.selectedObject;
          return GestureDetector(
            onTap: () => viewModel.selectObject(object),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple
                    : Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  object,
                  style: const TextStyle(color: AppColors.white, fontSize: 10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.white),
            SizedBox(height: 16),
            Text(
              'Saving to RoomieLab...',
              style: TextStyle(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: AppColors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: AppColors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white, size: 16),
              onPressed: () {
                viewModel.initializeCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARGridOverlay() {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _ARGridPainter(),
        ),
      ),
    );
  }

  Future<void> _saveToRoomieLab(BuildContext context, CameraViewModel viewModel) async {
    final success = await viewModel.saveProjectToRoomieLab(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project saved to RoomieLab!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context); // Go back to RoomieLab page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save project: ${viewModel.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _ARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Center crosshair
    final centerPaint = Paint()
      ..color = AppColors.success.withOpacity(0.6)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(size.width / 2 - 20, size.height / 2),
      Offset(size.width / 2 + 20, size.height / 2),
      centerPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 20),
      Offset(size.width / 2, size.height / 2 + 20),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlacedObjectsPainter extends CustomPainter {
  final List<design_models.DesignObject> placedObjects;

  _PlacedObjectsPainter(this.placedObjects);

  @override
  void paint(Canvas canvas, Size size) {
    for (final obj in placedObjects) {
      final paint = Paint()
        ..color = AppColors.primaryPurple.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      final position = Offset(
        obj.position.x * size.width,
        obj.position.y * size.height,
      );

      // Draw a simple rectangle for the placed object
      final rect = Rect.fromCenter(
        center: position,
        width: 40 * obj.scale.x,
        height: 40 * obj.scale.y,
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(obj.rotation.z * (3.14159 / 180));
      canvas.translate(-position.dx, -position.dy);

      canvas.drawRect(rect, paint);

      // Draw object name
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getObjectName(obj.itemId),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - 30,
        ),
      );

      canvas.restore();
    }
  }

  String _getObjectName(String itemId) {
    final nameMap = {
      'sofa_001': 'Sofa',
      'chair_001': 'Chair',
      'table_001': 'Table',
      'bed_001': 'Bed',
      'lamp_001': 'Lamp',
    };
    return nameMap[itemId] ?? 'Object';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}