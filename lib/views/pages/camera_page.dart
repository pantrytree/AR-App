import 'dart:typed_data';
import 'package:Roomantics/utils/colors.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import '../../viewmodels/camera_viewmodel.dart';
import 'dart:math' as math;

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel()..loadFurnitureItems(),
      child: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'AR Furniture',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                // AR View
                ARView(
                  onARViewCreated: (
                      ARSessionManager sessionManager,
                      ARObjectManager objectManager,
                      ARAnchorManager anchorManager,
                      ARLocationManager locationManager,
                      ) {
                    viewModel.onARViewCreated(
                      sessionManager,
                      objectManager,
                      anchorManager,
                      locationManager,
                    );
                  },
                ),

                // Selected furniture info banner - UPDATED
                if (viewModel.selectedFurnitureItem != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chair,
                              color: AppColors.primaryLightPurple,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.selectedFurnitureItem!.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  viewModel.placedNodes.isEmpty
                                      ? 'Tap "Place" to add'
                                      : '${viewModel.placedNodes.length} objects placed - Tap "Place" to add more',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (viewModel.placedNodes.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${viewModel.placedNodes.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Error message
                if (viewModel.error != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 140,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red.shade700),
                            onPressed: () {
                              viewModel.resetFurniture();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom controls - UPDATED LAYOUT
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 20,
                      top: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Movement controls when object is placed
                        if (viewModel.isObjectPlaced) ...[
                          _buildMovementControls(viewModel),
                          SizedBox(height: 16),

                          Column(
                            children: [
                              // Rotation controls
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildControlButton(
                                    icon: Icons.rotate_left,
                                    label: 'Rotate L',
                                    onPressed: () => viewModel.rotateFurniture(-math.pi / 4),
                                  ),
                                  SizedBox(width: 16),
                                  _buildControlButton(
                                    icon: Icons.rotate_right,
                                    label: 'Rotate R',
                                    onPressed: () => viewModel.rotateFurniture(math.pi / 4),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Scale controls
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildControlButton(
                                    icon: Icons.remove_circle_outline,
                                    label: 'Smaller',
                                    onPressed: () => viewModel.scaleFurniture(-0.1),
                                  ),
                                  SizedBox(width: 12),
                                  // Scale indicator
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      '${(viewModel.currentScale * 100).toInt()}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  _buildControlButton(
                                    icon: Icons.add_circle_outline,
                                    label: 'Bigger',
                                    onPressed: () => viewModel.scaleFurniture(0.1),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Screenshot control
                              _buildControlButton(
                                icon: Icons.camera_alt,
                                label: 'Photo',
                                onPressed: () async {
                                  await viewModel.captureScreenshot();

                                  if (viewModel.lastScreenshot != null) {
                                    _showScreenshotPreview(
                                      context,
                                      viewModel.lastScreenshot!,
                                      viewModel,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],

                        // Main action buttons - FIXED LAYOUT
                        _buildActionButtons(viewModel),
                      ],
                    ),
                  ),
                ),

                // Loading indicator
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryLightPurple),
                          SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // NEW: Separate method for action buttons to handle layout properly
  Widget _buildActionButtons(CameraViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row: Select and Place buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Select Furniture button
            _buildActionButton(
              icon: Icons.list,
              label: 'Select',
              isPrimary: false,
              onPressed: () {
                _showFurnitureSelectionBottomSheet(context, viewModel);
              },
            ),

            SizedBox(width: 16),

            // Place button
            if (viewModel.selectedFurnitureItem != null)
              _buildActionButton(
                icon: Icons.add_circle,
                label: 'Place',
                isPrimary: true,
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.placeFurniture(),
              ),
          ],
        ),

        SizedBox(height: 12),

        // Second row: Remove buttons (only when objects are placed)
        if (viewModel.placedNodes.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Remove Last button
              _buildActionButton(
                icon: Icons.delete,
                label: 'Remove Last',
                isPrimary: false,
                isDestructive: true,
                onPressed: () => viewModel.removeLastFurniture(),
              ),

              SizedBox(width: 12),

              // Clear All button (only when multiple objects)
              if (viewModel.placedNodes.length > 1)
                _buildActionButton(
                  icon: Icons.delete_sweep,
                  label: 'Clear All',
                  isPrimary: false,
                  isDestructive: true,
                  onPressed: () => viewModel.removeAllFurniture(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildMovementControls(CameraViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Move Furniture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _buildDirectionalButton(
                    icon: Icons.arrow_upward,
                    onPressed: () => viewModel.moveFurniture(0, 0, -0.3),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDirectionalButton(
                        icon: Icons.arrow_back,
                        onPressed: () => viewModel.moveFurniture(-0.3, 0, 0),
                      ),
                      SizedBox(width: 60),
                      _buildDirectionalButton(
                        icon: Icons.arrow_forward,
                        onPressed: () => viewModel.moveFurniture(0.3, 0, 0),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildDirectionalButton(
                    icon: Icons.arrow_downward,
                    onPressed: () => viewModel.moveFurniture(0, 0, 0.3),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionalButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryLightPurple),
        iconSize: 24,
        onPressed: onPressed,
        padding: EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            iconSize: 24,
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    bool isDestructive = false,
    VoidCallback? onPressed,
  }) {
    final Color backgroundColor = isDestructive
        ? Colors.red.shade600
        : isPrimary
        ? AppColors.primaryLightPurple
        : Colors.white;

    final Color foregroundColor = isPrimary || isDestructive ? Colors.white : Color(0xFF6750A4);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Slightly smaller radius
        ),
        elevation: 4,
        shadowColor: backgroundColor.withOpacity(0.5),
      ),
      icon: Icon(icon, size: 20), // Smaller icon
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14, // Smaller font
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }

  // ... keep the rest of your methods (_showFurnitureSelectionBottomSheet, _showScreenshotPreview, _showDesignNameDialog) the same ...
  void _showFurnitureSelectionBottomSheet(BuildContext context, CameraViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Furniture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLightPurple,
                ),
              ),
            ),

            // Furniture list
            Expanded(
              child: viewModel.isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primaryLightPurple))
                  : viewModel.availableFurnitureItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chair_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No furniture items available',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: viewModel.availableFurnitureItems.length,
                itemBuilder: (context, index) {
                  final item = viewModel.availableFurnitureItems[index];
                  final isSelected = viewModel.selectedFurnitureItem?.id == item.id;

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryLightPurple : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: item.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLightPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.chair, size: 30, color: AppColors.primaryLightPurple),
                              ),
                        ),
                      )
                          : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.chair, size: 30, color: AppColors.primaryLightPurple),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            item.category,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (item.arModelUrl != null)
                            Row(
                              children: [
                                Icon(Icons.view_in_ar, size: 12, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'AR Ready',
                                  style: TextStyle(fontSize: 10, color: Colors.green),
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppColors.primaryLightPurple, size: 28)
                          : Icon(Icons.circle_outlined, color: Colors.grey[300], size: 28),
                      onTap: () {
                        viewModel.selectFurnitureItem(item);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text('${item.name} selected!'),
                                ),
                              ],
                            ),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primaryLightPurple,
                          ),
                        );
                      },
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

  void _showScreenshotPreview(
      BuildContext context,
      Uint8List imageBytes,
      CameraViewModel viewModel,
      ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo_camera, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Screenshot Preview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Image Preview
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                padding: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Save to RoomieLab button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLightPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: Icon(Icons.workspace_premium),
                        label: Text(
                          'Save to RoomieLab',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          // Show design name dialog
                          final designName = await _showDesignNameDialog(context);

                          if (designName != null && designName.isNotEmpty) {
                            final success = await viewModel.saveDesign(designName);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text('Design "$designName" saved to RoomieLab!'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } else if (viewModel.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(child: Text(viewModel.error!)),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 12),

                    // Save to Gallery button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLightPurple,
                          side: BorderSide(color: AppColors.primaryLightPurple, width: 2),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.photo_library),
                        label: Text(
                          'Save to Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          final success = await viewModel.saveToGallery();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Saved to gallery!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else if (viewModel.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.white),
                                    SizedBox(width: 12),
                                    Expanded(child: Text(viewModel.error!)),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showDesignNameDialog(BuildContext context) async {
    final nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Save Design',
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Design Name *', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'e.g., My Living Room Design',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
                ),
              ),
              autofocus: true,
            ),
            SizedBox(height: 8),
            Text(
              'Room type will be determined automatically based on selected furniture.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.splashScreenBackground,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a design name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context, nameController.text);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
