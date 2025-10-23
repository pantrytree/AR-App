import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:vector_math/vector_math_64.dart';

class CameraViewModel extends ChangeNotifier {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  ARNode? _placedNode;
  bool _isObjectPlaced = false;

  bool get isObjectPlaced => _isObjectPlaced;

  void onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    _arSessionManager = sessionManager;
    _arObjectManager = objectManager;
    _arAnchorManager = anchorManager;

    _arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
    );

    _arObjectManager!.onInitialize();
    notifyListeners();
  }

  Future<void> placeOrRemoveAstronaut() async {
    if (_isObjectPlaced) {
      await resetAstronaut();
      return;
    }

    final node = ARNode(
      type: NodeType.webGLB,
      uri: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
      scale: Vector3(0.5, 0.5, 0.5),
      position: Vector3(0, 0, -1), // fixed 1m in front
    );

    bool didAdd = await _arObjectManager!.addNode(node) ?? false;
    if (didAdd) {
      _placedNode = node;
      _isObjectPlaced = true;
    }

    notifyListeners();
  }

  Future<void> moveAstronautForward() async {
    if (_placedNode == null) return;

    // Move forward 0.5m along Z-axis
    final currentPos = _placedNode!.position;
    final newPos = Vector3(currentPos.x, currentPos.y, currentPos.z - 0.5);

    await _arObjectManager!.removeNode(_placedNode!);

    final node = ARNode(
      type: NodeType.webGLB,
      uri: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
      scale: Vector3(0.5, 0.5, 0.5),
      position: newPos,
    );

    bool didAdd = await _arObjectManager!.addNode(node) ?? false;
    if (didAdd) _placedNode = node;

    notifyListeners();
  }

  Future<void> resetAstronaut() async {
    if (_placedNode != null) {
      await _arObjectManager!.removeNode(_placedNode!);
      _placedNode = null;
    }
    _isObjectPlaced = false;
    notifyListeners();
  }

  void disposeAR() {
    _arSessionManager?.dispose();
  }

  @override
  void dispose() {
    disposeAR();
    super.dispose();
  }
}
