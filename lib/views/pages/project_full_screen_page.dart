import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:Roomantics/viewmodels/roomielab_viewmodel.dart';
import 'package:Roomantics/models/project.dart';

class ProjectFullScreenPage extends StatefulWidget {
  final String projectId;

  const ProjectFullScreenPage({super.key, required this.projectId});

  @override
  State<ProjectFullScreenPage> createState() => _ProjectFullScreenPageState();
}

class _ProjectFullScreenPageState extends State<ProjectFullScreenPage> {
  Project? _project;
  bool _isLoading = true;
  String? _errorMessage;
  bool _usingFallbackImage = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    try {
      final viewModel = Provider.of<RoomieLabViewModel>(context, listen: false);
      final project = await viewModel.getProject(widget.projectId);

      setState(() {
        _project = project;
        _isLoading = false;
        _currentImageUrl = project?.imageUrl;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load project: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _shouldUseLocalFallback(String? imageUrl) {
    if (imageUrl == null) return false;

    return (_usingFallbackImage && _hasLocalBackup()) ||
        (imageUrl.startsWith('/') || imageUrl.contains('file://'));
  }

  bool _hasLocalBackup() {
    return _project?.imageUrl?.startsWith('/') ?? false;
  }

  /// Get the local backup image path
  String? _getLocalBackupPath() {
    final imageUrl = _project?.imageUrl;
    if (imageUrl == null) return null;

    // Return local path if it exists and is a file path
    if (imageUrl.startsWith('/') || imageUrl.contains('file://')) {
      return imageUrl.replaceFirst('file://', '');
    }
    return null;
  }

  /// Switch to local fallback image
  void _switchToLocalFallback() {
    final localPath = _getLocalBackupPath();
    if (localPath != null && File(localPath).existsSync()) {
      setState(() {
        _usingFallbackImage = true;
        _currentImageUrl = localPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _project?.name ?? 'Project View',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Show indicator when using fallback
          if (_usingFallbackImage)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.wifi_off,
                size: 20,
                color: Colors.orange[300],
                semanticLabel: 'Using local backup image',
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
          ? _buildErrorState()
          : _currentImageUrl != null || _hasLocalBackup()
          ? _buildImageView()
          : _buildNoImageState(),
    );
  }

  Widget _buildImageView() {
    final shouldUseLocal = _shouldUseLocalFallback(_currentImageUrl);
    final imageSource = shouldUseLocal ? _getLocalBackupPath() : _currentImageUrl;

    return Stack(
      children: [
        // Main Image Viewer
        Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 3.0,
            child: shouldUseLocal
                ? _buildLocalImage(imageSource!)
                : _buildNetworkImage(imageSource!),
          ),
        ),

        // Fallback indicator
        if (_usingFallbackImage)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[800]!.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Using local backup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading from Cloudinary...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Try to switch to local fallback if available
        if (_hasLocalBackup() && !_usingFallbackImage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _switchToLocalFallback();
          });
          return _buildLoadingFallback('Switching to local backup...');
        }
        return _buildErrorImage();
      },
    );
  }

  Widget _buildLocalImage(String filePath) {
    final file = File(filePath);

    if (!file.existsSync()) {
      return _buildErrorImage();
    }

    return Image.file(
      file,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorImage();
      },
    );
  }

  Widget _buildLoadingFallback(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Failed to load image',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        if (_hasLocalBackup() && !_usingFallbackImage) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _switchToLocalFallback,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Use Local Backup'),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          _currentImageUrl ?? 'No image URL',
          style: const TextStyle(color: Colors.grey, fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNoImageState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No image available',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _project?.name ?? 'Project',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (_hasLocalBackup()) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _switchToLocalFallback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Load Local Backup'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Failed to load project',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
          if (_hasLocalBackup()) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _switchToLocalFallback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Load Local Backup Only'),
            ),
          ],
        ],
      ),
    );
  }
}