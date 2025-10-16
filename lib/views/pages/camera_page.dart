// ignore_for_file: deprecated_member_use, unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
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
      ],
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
      onTap: ()=> viewModel.captureImage(context),
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
        child: CircularProgressIndicator(color: AppColors.white),
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
              onPressed: () => viewModel.initializeCamera(),
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

  void _saveToRoomieLab(BuildContext context, CameraViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved to RoomieLab')),
    );
    Navigator.pop(context); // Go back to RoomieLab page
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
