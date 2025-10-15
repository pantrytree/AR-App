// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../viewmodels/camera_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';
import '../../theme/theme.dart';
import '../../views/widgets/bottom_nav_bar.dart';

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
      body: SafeArea( // ADDED SafeArea to prevent overflow
        child: Consumer<CameraViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // REAL Camera Preview
                _buildCameraPreview(viewModel, context),

                // AR Grid Overlay
                if (viewModel.isCameraReady) _buildARGridOverlay(),

                // Controls - Reordered for better layout
                _buildTopControls(viewModel, context),
                _buildObjectSelectionPanel(viewModel, context),
                _buildBottomControls(viewModel, context),

                // Loading & Error States
                if (viewModel.isLoading) _buildLoadingOverlay(context),
                if (viewModel.error != null) _buildErrorMessage(viewModel, context),
              ],
            );
          },
        ),
      ),
    );
  }

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
            if (viewModel.isLoading) ...[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              viewModel.isLoading ? 'Starting Camera...' : 'Camera Not Available',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
            if (viewModel.error != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  viewModel.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      top: 20, // Removed MediaQuery padding since we're using SafeArea
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Camera Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.camera,
                  color: AppColors.white,
                  size: 20,
                ),
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

          // Switch Camera button
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

  Widget _buildObjectSelectionPanel(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      top: 100, // Simplified position
      left: 0,
      right: 0,
      child: Container(
        height: 80, // Reduced height
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 4.0), // Reduced padding
              child: Text(
                'Select Furniture:',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Smaller font
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.availableObjects.length,
                itemBuilder: (context, index) {
                  final object = viewModel.availableObjects[index];
                  final isSelected = object == viewModel.selectedObject;
                  return GestureDetector(
                    onTap: () => viewModel.selectObject(object),
                    child: Container(
                      width: 70, // Smaller width
                      margin: const EdgeInsets.only(right: 8), // Reduced margin
                      padding: const EdgeInsets.all(8), // Reduced padding
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppColors.white : Colors.transparent,
                          width: 1, // Thinner border
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getObjectIcon(object),
                            color: AppColors.white,
                            size: 20, // Smaller icon
                          ),
                          const SizedBox(height: 4),
                          Text(
                            object,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 8, // Smaller font
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildBottomControls(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      bottom: 10, // Fixed position without padding calculations
      left: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected object info - only show if needed
          if (viewModel.isObjectPlaced)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${viewModel.selectedObject} Placed',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Smaller font
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 16),
                    onPressed: viewModel.removeObject,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Capture button
          GestureDetector(
            onTap: viewModel.captureImage,
            child: Container(
              width: 60, // Smaller button
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
                color: Colors.transparent,
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: AppColors.black,
                  size: 24, // Smaller icon
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Place object button - only show if no object is placed
          if (!viewModel.isObjectPlaced)
            GestureDetector(
              onTap: viewModel.placeObject,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Place ${viewModel.selectedObject}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12, // Smaller font
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildARGridOverlay() {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: _ARGridPainter(),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
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

  IconData _getObjectIcon(String object) {
    switch (object.toLowerCase()) {
      case 'sofa': return Icons.weekend;
      case 'chair': return Icons.chair;
      case 'table': return Icons.table_restaurant;
      case 'bed': return Icons.bed;
      case 'lamp': return Icons.lightbulb;
      default: return Icons.widgets;
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