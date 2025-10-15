import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../utils/colors.dart';
import '../../theme/theme.dart';

/// EditProfilePage allows the user to update profile information:
/// name, email, username, password, and profile image.
/// This page is accessed from the side menu and does not include
/// the bottom navigation bar, keeping navigation clean and focused.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

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
    _passwordController = TextEditingController(text: viewModel.password);

    // Load existing user profile after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.loadUserProfile();
      _nameController.text = viewModel.name;
      _emailController.text = viewModel.email;
      _usernameController.text = viewModel.username;
      _passwordController.text = viewModel.password;
    });
  }

  @override
  void dispose() {
    // Dispose controllers to free memory
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
                        _buildPasswordField(
                          context,
                          controller: _passwordController,
                          onChanged: viewModel.setPassword,
                          viewModel: viewModel,
                        ),
                        const SizedBox(height: 40),
                        _isSaving
                            ? const Center(child: CircularProgressIndicator()) // Show loader while saving
                            : _buildSaveButton(context, viewModel),
                      ],
                    ),
                  ),
                ),
                // No bottom navigation bar - this page is accessed from side menu
                // Users return via back button or save action
              );
            },
          );
        },
      ),
    );
  }

  /// Builds profile avatar with an overlay camera icon.
  /// Clicking it should allow changing the profile image.
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
                color: AppColors.primaryLightPurple, // Keep brand color
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
  /// Supports required validation and keyboard type customization.
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

  /// Builds the password field with show/hide functionality.
  /// Uses ViewModel to track obscure text state.
  Widget _buildPasswordField(
      BuildContext context, {
        required TextEditingController controller,
        required void Function(String) onChanged,
        required EditProfileViewModel viewModel,
      }) {
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.getTextFieldBackground(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: viewModel.obscurePassword,
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
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.getSecondaryTextColor(context),
                ),
                onPressed: () => viewModel.togglePasswordVisibility(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the save button and handles saving the profile via the ViewModel.
  /// Displays a loading indicator while saving.
  Widget _buildSaveButton(BuildContext context, EditProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
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
            // Optionally navigate back after successful save
            // Navigator.pop(context);
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
    );
  }
}