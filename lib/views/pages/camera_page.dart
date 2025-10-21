import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../models/design_object.dart' as design_models;
import '../../viewmodels/camera_viewmodel.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;
import '../../utils/colors.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Use Flutter's BuildContext explicitly
      final BuildContext ctx = context;
      final viewModel = Provider.of<CameraViewModel>(ctx, listen: false);
      viewModel.initializeCamera();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraViewModel>(
        builder: (BuildContext context, CameraViewModel viewModel,
            Widget? child) {
          if (!viewModel.isCameraReady || viewModel.controller == null) {
            return _buildCameraPlaceholder(viewModel);
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(viewModel.controller!),
              if (viewModel.placedObjects
                  .isNotEmpty) _buildPlacedObjectsOverlay(viewModel),
              _buildTopControls(viewModel, context),
              _buildObjectPlacementControls(viewModel),

              _buildFurnitureCards(viewModel),
              Align(
                alignment: Alignment.bottomCenter,
                child: viewModel.capturedImagePath != null
                    ? _buildCaptureAndSaveButtons(viewModel, context)
                    : _buildCaptureButton(viewModel),
              ),
              if (viewModel.isLoading) _buildLoadingOverlay(),
              if (viewModel.error != null) _buildErrorMessage(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPlaceholder(CameraViewModel viewModel) {
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
              viewModel.isLoading
                  ? 'Starting Camera...'
                  : 'Camera Not Available',
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
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildPlacedObjectsOverlay(CameraViewModel viewModel) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _PlacedObjectsPainter(viewModel.placedObjects),
        ),
      ),
    );
  }

  Widget _buildObjectPlacementControls(CameraViewModel viewModel) {
    return Positioned(
      right: 20,
      top: 100,
      child: Column(
        children: [
          // Remove last placed object
          if (viewModel.isObjectPlaced)
            FloatingActionButton.small(
              onPressed: () {
                if (viewModel.selectedFurnitureItem != null) {
                  print('🔄 Attempting to place AR object...');
                  viewModel.placeARObject(
                    viewModel.selectedFurnitureItem!,
                    vmath.Vector3(0, 0, -1.0),
                    0.1,
                    0.0,
                  );
                } else {
                  print('❌ No furniture item selected');
                }
              },
              backgroundColor: AppColors.primaryPurple,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          const SizedBox(height: 20),

          // Rotation control
          FloatingActionButton.small(
            onPressed: () => viewModel.rotateARObject(45), // example 45 deg
            backgroundColor: Colors.orange,
            child: const Icon(Icons.rotate_right, color: Colors.white),
          ),
          const SizedBox(height: 10),

          // Scale control
          FloatingActionButton.small(
            onPressed: () => viewModel.scaleARObject(1.2),
            backgroundColor: Colors.green,
            child: const Icon(Icons.zoom_in, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Widget _buildFurnitureCards(CameraViewModel viewModel) {
  //   return Positioned(
  //     bottom: 120,
  //     left: 0,
  //     right: 0,
  //     child: SizedBox(
  //       height: 100,
  //       child: ListView.builder(
  //         scrollDirection: Axis.horizontal,
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         itemCount: viewModel.availableFurnitureItems.length,
  //         itemBuilder: (context, index) {
  //           final item = viewModel.availableFurnitureItems[index];
  //           final isSelected = viewModel.selectedFurnitureItem == item;
  //
  //           return GestureDetector(
  //             onTap: () => viewModel.selectFurnitureItem(item),
  //             child: Container(
  //               width: 80,
  //               margin: const EdgeInsets.symmetric(horizontal: 8),
  //               decoration: BoxDecoration(
  //                 color: isSelected ? AppColors.primaryPurple : Colors.grey[800],
  //                 borderRadius: BorderRadius.circular(12),
  //                 border: isSelected
  //                     ? Border.all(color: AppColors.success, width: 2)
  //                     : null,
  //               ),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.chair, color: Colors.white), // replace with thumbnail
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     item.name,
  //                     style: const TextStyle(
  //                         color: Colors.white, fontSize: 12),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFurnitureCards(CameraViewModel viewModel) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: viewModel.availableFurnitureItems.length,
          itemBuilder: (context, index) {
            final item = viewModel.availableFurnitureItems[index];
            final isSelected = viewModel.selectedFurnitureItem == item;

            return GestureDetector(
              onTap: () => viewModel.selectFurnitureItem(item),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryPurple : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.success, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // OPTION 2: Just show AR icon (better than chair)
                    // Icon(Icons.view_in_ar, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCaptureAndSaveButtons(CameraViewModel viewModel,
      BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: viewModel.resetCapture,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text("Retake"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _saveToRoomieLab(viewModel, context),
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text("Save to RoomieLab"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
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

  Widget _buildErrorMessage(CameraViewModel viewModel) {
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
              onPressed: viewModel.initializeCamera,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToRoomieLab(CameraViewModel viewModel,
      BuildContext context) async {
    final success = await viewModel.saveProjectToRoomieLab(context);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project saved to RoomieLab!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save project: ${viewModel.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildCaptureButton(CameraViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.captureImage(context),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.transparent,
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
        ),
      ),
    );
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