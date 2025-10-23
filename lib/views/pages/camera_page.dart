import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import '../../viewmodels/camera_viewmodel.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraViewModel(),
      child: Scaffold(
        body: Consumer<CameraViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                ARView(
                  planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
                  onARViewCreated: (sessionManager, objectManager, anchorManager, locationManager) {
                    viewModel.onARViewCreated(
                      sessionManager,
                      objectManager,
                      anchorManager,
                      locationManager,
                    );
                  },
                ),
                Positioned(
                  bottom: 120,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: viewModel.placeOrRemoveAstronaut,
                    child: Text(viewModel.isObjectPlaced ? "Remove Astronaut" : "Place Astronaut"),
                  ),
                ),
                Positioned(
                  bottom: 70,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: viewModel.moveAstronautForward,
                    child: const Text("Move Forward"),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: viewModel.resetAstronaut,
                    child: const Text("Reset"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
