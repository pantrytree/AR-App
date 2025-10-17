import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/utils/colors.dart';
import '/models/design_object.dart' as design_models;
import '/models/design.dart';

/// Project Editing Screen with Backend Integration
class ProjectEditPage extends StatefulWidget {
  final String projectId;
  final String? designId;
  final String furnitureItemId;
  final String furnitureName;

  const ProjectEditPage({
    super.key,
    required this.projectId,
    this.designId,
    required this.furnitureItemId,
    required this.furnitureName,
  });

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  late double _positionX;
  late double _positionY;
  late double _rotation;
  late double _scale;

  design_models.DesignObject? _currentDesignObject;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _positionX = 0.5;
    _positionY = 0.5;
    _rotation = 0.0;
    _scale = 1.0;

    // Load existing design object if available
    _loadDesignObject();
  }

  /// Load existing design object for this furniture item
  Future<void> _loadDesignObject() async {
    if (widget.designId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      final designs = await viewModel.getProjectDesigns(widget.projectId);

      if (designs.isNotEmpty) {
        final design = designs.first; // Use first design for this project
        final existingObject = design.objects.firstWhere(
              (obj) => obj.itemId == widget.furnitureItemId,
          orElse: () => design_models.DesignObject(
            itemId: widget.furnitureItemId,
            position: design_models.Position(x: 0.5, y: 0.5, z: 0.0),
            rotation: design_models.Rotation(x: 0.0, y: 0.0, z: 0.0),
            scale: design_models.Scale.uniform(1.0),
          ),
        );

        _currentDesignObject = existingObject;
        _positionX = existingObject.position.x;
        _positionY = existingObject.position.y;
        _rotation = existingObject.rotation.z; // Using Z rotation for 2D
        _scale = existingObject.scale.x; // Using uniform scale
      }
    } catch (e) {
      print('Error loading design object: $e');
      // Continue with default values
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.furnitureName}'),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Instructions - Fixed height container
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 20, color: AppColors.primaryPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Drag to move • Pinch to scale • Rotate with two fingers',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextColor(context),
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),

          // Design canvas - Use Expanded to take remaining space
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                setState(() {
                  // Update position based on drag
                  _positionX += details.focalPointDelta.dx / 500;
                  _positionY += details.focalPointDelta.dy / 500;

                  // Update rotation
                  _rotation += details.rotation;

                  // Update scale
                  _scale = (_scale * details.scale).clamp(0.5, 3.0);

                  // Clamp position to bounds
                  _positionX = _positionX.clamp(0.0, 1.0);
                  _positionY = _positionY.clamp(0.0, 1.0);

                  // Normalize rotation to 0-360 degrees
                  _rotation = _rotation % 360;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Stack(
                  children: [
                    // Background grid pattern
                    _buildGridPattern(),

                    // Furniture item
                    Positioned(
                      left: _positionX * MediaQuery.of(context).size.width - 50,
                      top: _positionY * MediaQuery.of(context).size.height - 50,
                      child: Transform.rotate(
                        angle: _rotation * (3.14159 / 180), // Convert to radians
                        child: Transform.scale(
                          scale: _scale,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryPurple,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.primaryPurple.withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min, // Prevent overflow
                                children: [
                                  Icon(
                                    _getFurnitureIcon(widget.furnitureName),
                                    size: 32, // Reduced size
                                    color: AppColors.primaryPurple,
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      widget.furnitureName,
                                      style: TextStyle(
                                        fontSize: 10, // Reduced font size
                                        color: AppColors.primaryPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2, // Prevent text overflow
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Position indicators
                    _buildPositionIndicators(),
                  ],
                ),
              ),
            ),
          ),

          // Controls - Fixed height section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                // Position and rotation info
                _buildTransformInfo(),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _resetPosition,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveChanges,
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build background grid pattern
  Widget _buildGridPattern() {
    return CustomPaint(
      painter: _GridPainter(),
      size: Size.infinite,
    );
  }

  /// Build position and rotation indicators
  Widget _buildPositionIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top-left position indicator
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'X: ${_positionX.toStringAsFixed(2)}\nY: ${_positionY.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  /// Build transform information display
  Widget _buildTransformInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Position', '${_positionX.toStringAsFixed(2)}, ${_positionY.toStringAsFixed(2)}'),
          _buildInfoItem('Rotation', '${_rotation.toStringAsFixed(1)}°'),
          _buildInfoItem('Scale', '${_scale.toStringAsFixed(2)}x'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent overflow
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Save changes to backend
  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

      // Create updated design object
      final updatedObject = design_models.DesignObject(
        itemId: widget.furnitureItemId,
        position: design_models.Position(x: _positionX, y: _positionY, z: 0.0),
        rotation: design_models.Rotation(x: 0.0, y: 0.0, z: _rotation),
        scale: design_models.Scale.uniform(_scale),
      );

      // Get or create design for this project
      final designs = await viewModel.getProjectDesigns(widget.projectId);
      Design design;

      if (designs.isEmpty) {
        // Create new design
        await viewModel.updateProjectDesign(
          widget.projectId,
          [updatedObject],
        );
      } else {
        // Update existing design
        design = designs.first;
        final updatedObjects = design.objects
            .where((obj) => obj.itemId != widget.furnitureItemId)
            .toList();
        updatedObjects.add(updatedObject);

        await viewModel.updateProjectDesign(
          widget.projectId,
          updatedObjects,
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Design updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save changes: ${e.toString()}';
      });
      print('Error saving design: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetPosition() {
    setState(() {
      _positionX = 0.5;
      _positionY = 0.5;
      _rotation = 0.0;
      _scale = 1.0;
    });
  }

  IconData _getFurnitureIcon(String furnitureName) {
    final name = furnitureName.toLowerCase();
    if (name.contains('sofa') || name.contains('couch')) return Icons.weekend;
    if (name.contains('chair')) return Icons.chair;
    if (name.contains('table')) return Icons.table_restaurant;
    if (name.contains('bed')) return Icons.bed;
    if (name.contains('lamp') || name.contains('light')) return Icons.lightbulb;
    if (name.contains('desk')) return Icons.desktop_mac;
    if (name.contains('cabinet') || name.contains('shelf')) return Icons.shelves;
    return Icons.help;
  }
}

/// Custom painter for grid background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}