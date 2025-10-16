import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:roomantics/utils/colors.dart';

/// Project Editing Screen
class ProjectEditPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectEditPage({super.key, required this.project});

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  double _positionX = 0.5;
  double _positionY = 0.5;
  double _rotation = 0.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _positionX = widget.project['positionX'] ?? 0.5;
    _positionY = widget.project['positionY'] ?? 0.5;
    _rotation = widget.project['rotation'] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        backgroundColor: AppColors.getAppBarBackground(context),
        foregroundColor: AppColors.getAppBarForeground(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app, size: 20, color: AppColors.primaryPurple),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Drag to move • Pinch to scale • Rotate with two fingers',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                setState(() {
                  _positionX += details.focalPointDelta.dx / 500;
                  _positionY += details.focalPointDelta.dy / 500;
                  _rotation += details.rotation;
                  _scale = details.scale.clamp(0.5, 3.0);
                  _positionX = _positionX.clamp(0.0, 1.0);
                  _positionY = _positionY.clamp(0.0, 1.0);
                });
              },
              child: Stack(
                children: [
                  Image.file(
                    File(widget.project['imagePath']),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    left: _positionX * MediaQuery.of(context).size.width - 50,
                    top: _positionY * MediaQuery.of(context).size.height - 50,
                    child: Transform.rotate(
                      angle: _rotation,
                      child: Transform.scale(
                        scale: _scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryPurple, width: 3),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primaryPurple.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getFurnitureIcon(widget.project['furniture']),
                                  size: 40,
                                  color: AppColors.primaryPurple,
                                ),
                                Text(
                                  widget.project['furniture'] ?? 'Furniture',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetPosition,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    viewModel.updateProjectPosition(
      widget.project['id'],
      _positionX,
      _positionY,
      _rotation,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project updated successfully!')),
    );
    Navigator.of(context).pop();
  }

  void _resetPosition() {
    setState(() {
      _positionX = 0.5;
      _positionY = 0.5;
      _rotation = 0.0;
      _scale = 1.0;
    });
  }

  IconData _getFurnitureIcon(String? furniture) {
    switch (furniture?.toLowerCase()) {
      case 'sofa': return Icons.weekend;
      case 'chair': return Icons.chair;
      case 'table': return Icons.table_restaurant;
      case 'bed': return Icons.bed;
      case 'lamp': return Icons.lightbulb;
      default: return Icons.help;
    }
  }
}