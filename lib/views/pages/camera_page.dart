import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:camera/camera.dart';
import '../../viewmodels/camera_viewmodel.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // Load furniture items and initialize camera when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CameraViewModel>(context, listen: false);
      viewModel.loadFurnitureItems();
      viewModel.initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // AR Flutter Plugin View (handles 3D models)
              _buildARView(viewModel),
              
              // AR Grid Overlay
              if (viewModel.isCameraReady) _buildARGridOverlay(),
              
              // UI Controls Overlay
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
            const Icon(Icons.error, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () {
                viewModel.clearError();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARView(CameraViewModel viewModel) {
    return ARView(
      onARViewCreated: (sessionManager, objectManager, anchorManager, locationManager) async {
        // Initialize AR session without debug visuals
        await sessionManager.onInitialize(
          showFeaturePoints: false,   // hides the small point cloud dots
          showPlanes: false,          // hides the default plane overlay
          showWorldOrigin: false,     // hides the origin axes
        );

        // Initialize the object manager (needed for placing objects)
        await objectManager.onInitialize();

        // Pass managers to your ViewModel
        viewModel.onARViewCreated(sessionManager, objectManager, anchorManager, locationManager);
      },
      // You can still detect planes without showing them
      planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
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
      top: 140,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Select Furniture:',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : viewModel.availableFurnitureItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No furniture items available',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.availableFurnitureItems.length,
                          itemBuilder: (context, index) {
                            final furnitureItem = viewModel.availableFurnitureItems[index];
                            final isSelected = furnitureItem == viewModel.selectedFurnitureItem;
                            return GestureDetector(
                              onTap: () => viewModel.selectFurnitureItem(furnitureItem),
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Use furniture item image if available, otherwise use default icon
                                    furnitureItem.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              furnitureItem.imageUrl!,
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  _getCategoryIcon(furnitureItem.category),
                                                  color: AppColors.white,
                                                  size: 24,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            _getCategoryIcon(furnitureItem.category),
                                            color: AppColors.white,
                                            size: 24,
                                          ),
                                    const SizedBox(height: 6),
                                    Text(
                                      furnitureItem.name,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sofa':
      case 'sofas':
        return Icons.chair;
      case 'chair':
      case 'chairs':
        return Icons.chair;
      case 'table':
      case 'tables':
        return Icons.table_bar;
      case 'bed':
      case 'beds':
        return Icons.bed;
      case 'lamp':
      case 'lamps':
        return Icons.lightbulb;
      case 'storage':
      case 'storage':
        return Icons.inventory_2;
      default:
        return Icons.widgets;
    }
  }

  Widget _buildBottomControls(CameraViewModel viewModel, BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Selected object info
          if (viewModel.isObjectPlaced)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${viewModel.selectedFurnitureItem?.name ?? "Item"} Placed',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: viewModel.removeObject,
                  ),
                ],
              ),
            ),

          // Capture button
          GestureDetector(
            onTap: viewModel.captureImage,
            child: Container(
              width: 70,
              height: 70,
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
                child: const Icon(
                  Icons.photo_camera,
                  color: AppColors.black,
                  size: 30,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          GestureDetector(
            onTap: viewModel.placeObject,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Tap to Place ${viewModel.selectedFurnitureItem?.name ?? "Item"}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
