import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../utils/colors.dart';
import '../../theme/theme.dart';
import 'change_passwords_page.dart';

/// EditProfilePage allows the user to update profile information:
/// name, email, username, and profile image.
/// Password field replaced with Change Password button.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  bool _isSaving = false; // Tracks if profile save operation is in progress

  @override
  void initState() {
    super.initState();

    // Initialize EditProfileViewModel
    final viewModel = EditProfileViewModel();

    // Initialize text controllers with initial values from the ViewModel
    _nameController = TextEditingController(text: viewModel.name);
    _emailController = TextEditingController(text: viewModel.email);
    _usernameController = TextEditingController(text: viewModel.username);

    // Load existing user profile after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.loadUserProfile();
      _nameController.text = viewModel.name;
      _emailController.text = viewModel.email;
      _usernameController.text = viewModel.username;
    });
  }

  @override
  void dispose() {
    // Dispose controllers to free memory
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
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
                    icon: Icon(Icons.arrow_back),
                    color: AppColors.getAppBarForeground(context),
                    onPressed: () => Navigator.pop(context), // Return to previous page
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileAvatar(context, viewModel), // Profile image section
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
                        _buildChangePasswordButton(context), // Replaced password field with button
                        const SizedBox(height: 40),
                        _isSaving
                            ? const Center(child: CircularProgressIndicator()) // Show loader while saving
                            : _buildSaveButton(context, viewModel),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds profile avatar with an overlay camera icon.
  Widget _buildProfileAvatar(BuildContext context, EditProfileViewModel viewModel) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Placeholder for image picker integration
          print('Change Photo clicked!');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.getCardBackground(context), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.getPrimaryColor(context)
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(context),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.getCardBackground(context), width: 2),
                      ),
                      child: Icon(
                          Icons.camera_alt,
                          color: AppColors.white,
                          size: 14
                      ),
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
            setState(() => _isSaving = true); // Show loader
            await viewModel.saveProfile(); // Call ViewModel API
            setState(() => _isSaving = false); // Hide loader

            // Show feedback message
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