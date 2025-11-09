import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../utils/colors.dart';
import '../../theme/theme.dart';
import 'change_passwords_page.dart';

// Page for users to edit their profile information including name, email, and profile picture
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late EditProfileViewModel _viewModel;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();

    _viewModel = EditProfileViewModel();

    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // Load profile data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.loadUserProfile();

      setState(() {
        _nameController.text = _viewModel.name;
        _emailController.text = _viewModel.email;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditProfileViewModel>.value(
      value: _viewModel,
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
                    onPressed: () => Navigator.pop(context), // Return to previous screen
                  ),
                ),
                body: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator()) // Loading state
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileAvatar(context, viewModel), // Profile picture section
                        const SizedBox(height: 30),

                        // Success message banner
                        if (viewModel.successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.successMessage!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Error message banner
                        if (viewModel.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Name input field
                        _buildTextField(
                          context,
                          label: 'Name',
                          controller: _nameController,
                          onChanged: viewModel.setName,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        
                        // Email input field
                        _buildTextField(
                          context,
                          label: 'E-mail Address',
                          controller: _emailController,
                          onChanged: viewModel.setEmail,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),

                        // Change password navigation button
                        _buildChangePasswordButton(context),
                      
                        const SizedBox(height: 40),

                        // Save profile button
                        _buildSaveButton(context, viewModel),
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

  // Builds profile avatar section with image picker functionality
  Widget _buildProfileAvatar(BuildContext context, EditProfileViewModel viewModel) {
    return Center(
      child: GestureDetector(
        onTap: () => _showImagePickerDialog(context, viewModel), // Open image picker options
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
                // Show selected image, existing photo, or default icon
                image: viewModel.profileImage != null
                    ? DecorationImage(
                  image: FileImage(viewModel.profileImage!),
                  fit: BoxFit.cover,
                )
                    : viewModel.photoUrl != null
                    ? DecorationImage(
                  image: NetworkImage(viewModel.photoUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Show default person icon if no image is set
                  if (viewModel.profileImage == null && viewModel.photoUrl == null)
                    Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.getPrimaryColor(context),
                    ),
                  // Camera icon overlay for changing photo
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.getCardBackground(context),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
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
                color: AppColors.getPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shows bottom sheet dialog for image selection options
  void _showImagePickerDialog(BuildContext context, EditProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Gallery option
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.getPrimaryColor(context)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImageFromGallery();
                },
              ),
              // Camera option
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.getPrimaryColor(context)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImageFromCamera();
                },
              ),
              // Remove photo option (only show if photo exists)
              if (viewModel.photoUrl != null || viewModel.profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.deleteProfileImage();
                  },
                ),
              // Cancel option
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Builds reusable text input field with consistent styling
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

  // Builds change password navigation button
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
              // Navigate to password change page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
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

  // Builds save profile button with loading state
  Widget _buildSaveButton(BuildContext context, EditProfileViewModel viewModel) {
    return Center(
      child: SizedBox(
        width: 120, 
        height: 50,
        child: ElevatedButton(
          onPressed: viewModel.isLoading
              ? null // Disable button during loading
              : () async {
            viewModel.clearError();
            viewModel.clearSuccess();

            final success = await viewModel.saveProfile();

            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.successMessage ?? 'Profile saved'),
                  backgroundColor: Colors.green,
                ),
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
          child: viewModel.isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Save',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
