// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/camera_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';
import '../../utils/theme.dart';

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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ChangeNotifierProvider(
          create: (_) => CameraViewModel(),
          child: Scaffold(
            backgroundColor: AppColors.getBackgroundColor(context),
            body: Consumer<CameraViewModel>(
              builder: (context, viewModel, child) {
                return Stack(
                  children: [
                    _buildCameraPreview(viewModel, context),
                    _buildTopControls(viewModel, context),
                    _buildBottomControls(viewModel, context),
                    if (viewModel.isARModeActive) _buildARObjectPanel(viewModel, context),
                    if (viewModel.isLoading) _buildLoadingOverlay(context),
                    if (viewModel.error != null) _buildErrorMessage(viewModel, context),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraPreview(CameraViewModel viewModel, BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.getBackgroundColor(context),
      child: viewModel.isCameraInitialized
          ? _buildCameraContent(viewModel, context)
          : _buildCameraPlaceholder(viewModel, context),
    );
  }

  Widget _buildCameraContent(CameraViewModel viewModel, BuildContext context) {
    return Stack(
      children: [
        Container(
          color: AppColors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  viewModel.isARModeActive ? Icons.view_in_ar : Icons.camera_alt,
                  size: 80,
                  color: AppColors.getTextColor(context),
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.isARModeActive ? 'AR View Mode' : 'Camera Mode',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 18,
                  ),
                ),
                if (viewModel.isARModeActive && viewModel.isObjectPlaced) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${viewModel.selectedObject} Placed in AR',
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (viewModel.isARModeActive) _buildARGridOverlay(),
      ],
    );
  }

  Widget _buildCameraPlaceholder(CameraViewModel viewModel, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.getPrimaryColor(context)),
          ),
          const SizedBox(height: 20),
          Text(
            'Initializing Camera...',
            style: TextStyle(color: AppColors.getTextColor(context), fontSize: 16),
          ),
          if (viewModel.error != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                viewModel.error!,
                style: TextStyle(color: AppColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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

  Widget _buildTopControls(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.getCardBackground(context).withOpacity(0.7),
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.getIconColor(context)),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context).withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  viewModel.isARModeActive ? Icons.camera_alt : Icons.view_in_ar,
                  color: AppColors.getIconColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: viewModel.toggleARMode,
                  child: Text(
                    viewModel.isARModeActive ? 'AR Mode' : 'Camera Mode',
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: AppColors.getCardBackground(context).withOpacity(0.7),
            child: IconButton(
              icon: Icon(Icons.settings, color: AppColors.getIconColor(context)),
              onPressed: () => _showSettingsDialog(context, viewModel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        children: [
          if (viewModel.isARModeActive) _buildARControls(viewModel, context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: viewModel.isARModeActive ? viewModel.placeObject : viewModel.captureImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.getTextColor(context), width: 4),
                    color: Colors.transparent,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildARControls(CameraViewModel viewModel, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context).withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Selected: ${viewModel.selectedObject}',
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (viewModel.isObjectPlaced)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: viewModel.removeObject,
            ),
        ],
      ),
    );
  }

  Widget _buildARObjectPanel(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: viewModel.availableObjects.length,
          itemBuilder: (context, index) {
            final object = viewModel.availableObjects[index];
            final isSelected = object == viewModel.selectedObject;
            return GestureDetector(
              onTap: () => viewModel.selectObject(object),
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.getPrimaryColor(context) : AppColors.getCardBackground(context).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.getTextColor(context) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getObjectIcon(object),
                      color: AppColors.getTextColor(context),
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      object,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: AppColors.getBackgroundColor(context).withOpacity(0.7),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.getPrimaryColor(context)),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () {},
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

  void _showSettingsDialog(BuildContext context, CameraViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Camera Settings',
          style: TextStyle(color: AppColors.getTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.getIconColor(context)),
              title: Text('Camera Resolution', style: TextStyle(color: AppColors.getTextColor(context))),
              subtitle: Text('High Definition', style: TextStyle(color: AppColors.getSecondaryTextColor(context))),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.flash_on, color: AppColors.getIconColor(context)),
              title: Text('Flash', style: TextStyle(color: AppColors.getTextColor(context))),
              subtitle: Text('Auto', style: TextStyle(color: AppColors.getSecondaryTextColor(context))),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.getPrimaryColor(context))),
          ),
        ],
      ),
    );
  }
}

class _ARGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const gridSize = 50.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final centerPaint = Paint()
      ..color = AppColors.success.withOpacity(0.6)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(size.width / 2 - 20, size.height / 2), Offset(size.width / 2 + 20, size.height / 2), centerPaint);
    canvas.drawLine(Offset(size.width / 2, size.height / 2 - 20), Offset(size.width / 2, size.height / 2 + 20), centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}