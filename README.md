# Roomantics - 3D Furniture AR Mobile App

## Overview

Roomantics is a cutting-edge mobile application that allows users to visualize furniture in their own space using augmented reality. Design, arrange, and preview 3D furniture models in real-time through your phone's camera.

## Features

### Core Functionality
- **AR Furniture Placement**: Precisely position 3D furniture models in your environment
- **Real-time Scaling & Rotation**: Intuitive gestures to resize and orient furniture
- **Project Management**: Save and organize multiple room designs
- **Furniture Catalog**: Browse and search hundreds of 3D furniture models
- **Collaboration**: Share projects with others for feedback

### Technical Features
- **Cross-Platform**: Built with Flutter for Android
- **High Performance**: Optimized 3D rendering at 60fps

## Tech Stack

### Frontend
- **Flutter 3.16** - Cross-platform framework
- **Dart 3.2** - Programming language
- **ARCore** - Augmented Reality
- **Provider** - State management

### Backend & Infrastructure
- **Firebase Auth** - User authentication & management
- **Cloud Firestore** - Real-time database
- **Cloudinary** - 2D asset storage
- **GitHub Repository** - 3D model asset storage
- **Node.js/Express** - Custom API endpoints

### 3D & Graphics
- **Sceneform** - AR rendering (Android)
- **glTF/GLB** - 3D model format

## Prerequisites
- Flutter SDK 3.16.0 or higher
- Android Studio
- Firebase project setup
- ARCore compatible device

### Installation
1. Clone the repository
*git clone https://github.com/your-username/roomantics.git*
*cd roomantics*

2. Install dependencies
*flutter pub get*

3. Configure Firebase
Download *google-services.json*
Place in appropriate directories

4. Run the application
*flutter run*

## Contributing
We welcome contributions! 

**Development Workflow**
1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request

**Code Standards**
Dart: Follows effective dart guidelines
Documentation: All public APIs documented
Commit Messages: Conventional commits format

### Common Issues
**AR not working:**
- Ensure device supports ARCore
- Check camera permissions
- Verify adequate lighting

**3D models not loading:**
- Check internet connection
- Verify Firebase Storage rules
- Clear app cache

Built with ❤️ by the Roomantics Team
