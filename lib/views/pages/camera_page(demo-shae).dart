import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';
import '../../views/widgets/bottom_nav_bar.dart';

/// CameraPage shows a placeholder for project-specific camera functionality.
/// Currently includes project info and a dummy bottom navigation bar.
class CameraPage extends StatelessWidget {
  final String projectId;
  final String projectName;

  const CameraPage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        title: Text(
          'Camera for $projectName',
          style: TextComponents.header16,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Camera page placeholder',
              style: TextComponents.header16,
            ),
            const SizedBox(height: 20),
            Text(
              'Project ID: $projectId',
              style: TextComponents.body13Grey,
            ),
            const SizedBox(height: 10),
            Text(
              'Project Name: $projectName',
              style: TextComponents.body13Grey,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Placeholder action: just go back
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Temporary dummy onTap for now
          print("BottomNavBar tapped index: $index");
        },
      ),
    );
  }
}
