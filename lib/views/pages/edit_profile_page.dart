import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:provider/provider.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../utils/colors.dart';
import '../../theme/theme.dart';
import 'change_passwords_page.dart';

/// EditProfilePage allows the user to update profile information:
/// name, email, username, and profile image.
/// Password field replaced with Change Password button.
/// Includes image picker functionality for profile photos.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();

    // Load user profile data from ViewModel after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<EditProfileViewModel>(context, listen: false);
      vm.loadUserProfile().then((_) {
        _nameController.text = vm.name;
        _emailController.text = vm.email;
        _usernameController.text = vm.username;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Opens a bottom sheet to let the user pick an image from the gallery
  /// or take a new photo with the camera
  Future<void> _pickImage(EditProfileViewModel vm) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pick from gallery
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80, // Compress to reduce size
                );
                if (picked != null) {
                  vm.setProfileImage(File(picked.path)); // Update ViewModel
                }
              },
            ),
            // Take a photo with camera
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (picked != null) {
                  vm.setProfileImage(File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditProfileViewModel>(
      create: (_) => EditProfileViewModel(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<EditProfileViewModel>(
            builder: (context, viewModel, child) {
              return Scaffold(
                backgroundColor: AppColors.getBackgroundColor(context),
                appBar: AppBar(
                  title: Text(
                    'Edit Profile',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getAppBarForeground(context),
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: AppColors.getAppBarBackground(context),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.getAppBarForeground(context),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image section with image picker
                        _buildProfileAvatar(context, viewModel),
                        const SizedBox(height: 30),
                        _buildTextField(
                          context,
                          label: 'Name',
                          controller: _nameController,
                          onChanged: viewModel.setName,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          context,
                          label: 'E-mail Address',
                          controller: _emailController,
                          onChanged: viewModel.setEmail,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          context,
                          label: 'User name',
                          controller: _usernameController,
                          onChanged: viewModel.setUsername,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        // Replaced password field with Change Password button
                        _buildChangePasswordButton(context),
                        const SizedBox(height: 40),
                        _isSaving
                            ? const Center(child: CircularProgressIndicator())
                            : _buildSaveButton(context, viewModel),
                        if (viewModel.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            viewModel.errorMessage!,
                            style: GoogleFonts.inter(color: Colors.red),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
                // No bottom navigation bar - accessed from side menu
              );
            },
          );
        },
      ),
    );
  }

  /// Builds profile avatar with image picker functionality
  Widget _buildProfileAvatar(BuildContext context, EditProfileViewModel viewModel) {
    final imageWidget = viewModel.localImage != null
        ? CircleAvatar(
      radius: 60,
      backgroundImage: FileImage(viewModel.localImage!),
      backgroundColor: AppColors.primaryLightPurple,
    )
        : CircleAvatar(
      radius: 60,
      backgroundImage: NetworkImage(viewModel.profileImageUrl),
      backgroundColor: AppColors.primaryLightPurple,
    );

    return Center(
      child: GestureDetector(
        onTap: () => _pickImage(viewModel),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipOval(child: imageWidget),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Change Photo',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.getPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a generic text field (name, email, username)
  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required void Function(String) onChanged,
        bool isRequired = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.getTextFieldBackground(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.getTextColor(context),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.getTextFieldBackground(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the Change Password button that navigates to ChangePasswordPage
  Widget _buildChangePasswordButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getCardBackground(context),
              foregroundColor: AppColors.getTextColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.getSecondaryTextColor(context).withOpacity(0.3),
                  width: 1,
                ),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Password',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the smaller save button and handles saving the profile
  Widget _buildSaveButton(BuildContext context, EditProfileViewModel viewModel) {
    return Center(
      child: SizedBox(
        width: 120, // Smaller width
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            viewModel.setName(_nameController.text);
            viewModel.setEmail(_emailController.text);
            viewModel.setUsername(_usernameController.text);

            setState(() => _isSaving = true);
            await viewModel.saveProfile();
            setState(() => _isSaving = false);

            if (viewModel.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(viewModel.errorMessage!)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile Saved")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getPrimaryColor(context),
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}