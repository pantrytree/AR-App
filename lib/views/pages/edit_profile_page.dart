import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../utils/colors.dart';
import '../widgets/bottom_nav_bar.dart';

/// EditProfilePage allows the user to update their profile information,
/// including name, email, username, password, and profile image.
///
/// This page is a child page under the Profile tab. It does not have its
/// own BottomNavBar index, but it displays the bar for visual consistency.
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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel and controllers
    final viewModel = EditProfileViewModel();

    _nameController = TextEditingController(text: viewModel.name);
    _emailController = TextEditingController(text: viewModel.email);
    _usernameController = TextEditingController(text: viewModel.username);
    _passwordController = TextEditingController(text: viewModel.password);

    // Load existing user data
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
      child: Consumer<EditProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            appBar: AppBar(
              title: Text(
                'Edit Profile',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              centerTitle: true,
              backgroundColor: AppColors.secondaryBackground,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.primaryDarkBlue,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileAvatar(viewModel),
                    const SizedBox(height: 30),
                    _buildTextField(
                      label: 'Name',
                      controller: _nameController,
                      onChanged: viewModel.setName,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'E-mail Address',
                      controller: _emailController,
                      onChanged: viewModel.setEmail,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'User name',
                      controller: _usernameController,
                      onChanged: viewModel.setUsername,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _passwordController,
                      onChanged: viewModel.setPassword,
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 40),
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : _buildSaveButton(viewModel),
                  ],
                ),
              ),
            ),
            // BottomNavBar stays consistent with main tabs
            bottomNavigationBar: BottomNavBar(
              currentIndex: 4, // Profile tab is active
              onTap: (index) {
                // Navigate to main tabs
                // EditProfile is child, so no change needed here
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds the profile avatar with a camera icon to change the photo
  Widget _buildProfileAvatar(EditProfileViewModel viewModel) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Integrate image picker for profile photo
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
                border: Border.all(
                  color: AppColors.white,
                  width: 3,
                ),
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
                  const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primaryPurple,
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 14,
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
                color: AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a general text field for name, email, or username
  Widget _buildTextField({
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
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textFieldBackground,
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
              color: AppColors.primaryDarkBlue,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.textFieldBackground,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the password input field with show/hide toggle
  Widget _buildPasswordField({
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
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
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
              color: AppColors.primaryDarkBlue,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.textFieldBackground,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                ),
                onPressed: () => viewModel.togglePasswordVisibility(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the save button and handles calling the ViewModel to save
  Widget _buildSaveButton(EditProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          setState(() => _isSaving = true);
          await viewModel.saveProfile(); // Calls ViewModel API placeholder
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
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Save',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
