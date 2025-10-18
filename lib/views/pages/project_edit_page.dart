import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/viewmodels/roomielab_viewmodel.dart';
import '/models/design.dart';
import '/models/design_object.dart';

class ProjectEditPage extends StatefulWidget {
  final String projectId;
  final String furnitureItemId;
  final String furnitureName;

  const ProjectEditPage({
    super.key,
    required this.projectId,
    required this.furnitureItemId,
    required this.furnitureName,
  });

  @override
  State<ProjectEditPage> createState() => _ProjectEditPageState();
}

class _ProjectEditPageState extends State<ProjectEditPage> {
  List<Design> _designs = [];
  Design? _selectedDesign;
  DesignObject? _selectedObject;

  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }

  Future<void> _loadDesigns() async {
    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    _designs = await viewModel.getProjectDesigns(widget.projectId);

    if (_designs.isNotEmpty) {
      _selectedDesign = _designs.first;
      // Auto-select the furniture item if it exists in the design
      if (_selectedDesign != null && _selectedDesign!.objects.isNotEmpty) {
        final existingObject = _selectedDesign!.objects.firstWhere(
              (obj) => obj.itemId == widget.furnitureItemId,
          orElse: () => DesignObject(
            itemId: widget.furnitureItemId,
            position: Position(x: 0, y: 0, z: 0),
            rotation: Rotation(x: 0, y: 0, z: 0),
            scale: Scale.identity(),
          ),
        );
        _selectedObject = existingObject;
      }
    }

    setState(() {});
  }

  void _onObjectTransformed(Map<String, dynamic> transformData) async {
    if (_selectedDesign == null || _selectedObject == null) return;

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);

    await viewModel.updateProjectDesign(
      projectId: widget.projectId,
      designId: _selectedDesign!.id,
      itemId: _selectedObject!.itemId,
      position: Position.fromJson(transformData['position']),
      rotation: Rotation.fromJson(transformData['rotation']),
      scale: Scale.fromJson(transformData['scale']),
    );
  }

  void _onObjectSelected(DesignObject designObject) {
    setState(() {
      _selectedObject = designObject;
    });
  }

  Future<void> _addObjectToDesign() async {
    if (_selectedDesign == null) return;

    final newObject = DesignObject(
      itemId: widget.furnitureItemId,
      position: Position(x: 0, y: 0, z: 0),
      rotation: Rotation(x: 0, y: 0, z: 0),
      scale: Scale.identity(),
    );

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    final success = await viewModel.addDesignObject(
      designId: _selectedDesign!.id,
      designObject: newObject,
    );

    if (success && mounted) {
      setState(() {
        _selectedObject = newObject;
      });
      await _loadDesigns(); // Refresh the designs
    }
  }

  Future<void> _createNewDesign() async {
    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    final designId = await viewModel.createDesign(
      projectId: widget.projectId,
      name: 'New Design ${_designs.length + 1}',
      objects: [],
    );

    if (designId != null && mounted) {
      await _loadDesigns(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
        actions: [
          if (_designs.isNotEmpty)
            DropdownButton<Design>(
              value: _selectedDesign,
              onChanged: (Design? newDesign) {
                setState(() {
                  _selectedDesign = newDesign;
                  _selectedObject = null;
                });
              },
              items: _designs.map((Design design) {
                return DropdownMenuItem<Design>(
                  value: design,
                  child: Text(design.name),
                );
              }).toList(),
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewDesign,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_designs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No designs found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createNewDesign,
              child: const Text('Create New Design'),
            ),
          ],
        ),
      );
    }

    if (_selectedDesign == null) {
      return const Center(child: Text('Select a design'));
    }

    return Column(
      children: [
        // Design info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Design: ${_selectedDesign!.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Objects: ${_selectedDesign!.objects.length}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Objects list
        Expanded(
          child: _selectedDesign!.objects.isEmpty
              ? const Center(child: Text('No objects in this design'))
              : ListView.builder(
            itemCount: _selectedDesign!.objects.length,
            itemBuilder: (context, index) {
              final object = _selectedDesign!.objects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: _selectedObject?.itemId == object.itemId
                    ? Colors.blue.withOpacity(0.1)
                    : null,
                child: ListTile(
                  title: Text('Object ID: ${object.itemId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Position: X:${object.position.x.toStringAsFixed(2)}, Y:${object.position.y.toStringAsFixed(2)}, Z:${object.position.z.toStringAsFixed(2)}'),
                      Text('Rotation: X:${object.rotation.x.toStringAsFixed(2)}°, Y:${object.rotation.y.toStringAsFixed(2)}°, Z:${object.rotation.z.toStringAsFixed(2)}°'),
                      Text('Scale: X:${object.scale.x.toStringAsFixed(2)}, Y:${object.scale.y.toStringAsFixed(2)}, Z:${object.scale.z.toStringAsFixed(2)}'),
                    ],
                  ),
                  onTap: () => _onObjectSelected(object),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeObject(object.itemId),
                  ),
                ),
              );
            },
          ),
        ),

        // Add object button and transform controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _addObjectToDesign,
                child: const Text('Add Object to Design'),
              ),
              const SizedBox(height: 16),
              if (_selectedObject != null) ...[
                Text(
                  'Selected: ${_selectedObject!.itemId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Example transform controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _onObjectTransformed({
                          'position': {'x': 1.0, 'y': 1.0, 'z': 1.0},
                          'rotation': {'x': 45.0, 'y': 0.0, 'z': 0.0},
                          'scale': {'x': 1.5, 'y': 1.5, 'z': 1.5},
                        });
                      },
                      child: const Text('Move'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _onObjectTransformed({
                          'position': {'x': 0.0, 'y': 0.0, 'z': 0.0},
                          'rotation': {'x': 90.0, 'y': 0.0, 'z': 0.0},
                          'scale': {'x': 1.0, 'y': 1.0, 'z': 1.0},
                        });
                      },
                      child: const Text('Rotate'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _removeObject(String itemId) async {
    if (_selectedDesign == null) return;

    final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
    final success = await viewModel.removeDesignObject(
      designId: _selectedDesign!.id,
      itemId: itemId,
    );

    if (success && mounted) {
      if (_selectedObject?.itemId == itemId) {
        _selectedObject = null;
      }
      await _loadDesigns(); // Refresh the designs
    }
  }
}