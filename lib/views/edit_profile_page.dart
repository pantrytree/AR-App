import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/edit_profile_viewmodel.dart';
import '../../utils/colors.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditProfileViewModel>(context, listen: false);

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
        backgroundColor: AppColors.secondaryBackground, // ✅
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primaryDarkBlue,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ChangeNotifierProvider(
          create: (_) => viewModel,
          child: Consumer<EditProfileViewModel>(
            builder: (context, model, child) {
              return Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileAvatar(),
                    const SizedBox(height: 30),

                    _buildTextField(
                      label: 'Name',
                      onChanged: model.setName,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'E-mail Address',
                      onChanged: model.setEmail,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'User name',
                      onChanged: model.setUsername,
                      isRequired: true,
                    ),
                    const SizedBox(height: 20),

                    _buildPasswordField(onChanged: model.setPassword),
                    const SizedBox(height: 40),

                    _buildSaveButton(viewModel),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: GestureDetector(
        onTap: () {
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
                  color: AppColors.white, // ✅
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

  Widget _buildTextField({
    required String label,
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
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.primaryDarkBlue, // ✅
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.textFieldBackground, // ✅
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({required void Function(String) onChanged}) {
    return Consumer<EditProfileViewModel>(
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDarkBlue, // ✅
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white, // ✅
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
                onChanged: onChanged,
                obscureText: model.obscurePassword,
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
                      model.obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.grey, // ✅
                    ),
                    onPressed: () => model.togglePasswordVisibility(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton(EditProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          viewModel.saveProfile();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary, // ✅ 原 Color(0xFF99a0d1)
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 4, // Profile tab
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, color: AppColors.black), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.favorite, color: AppColors.black), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt, color: AppColors.black), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag, color: AppColors.black), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person, color: AppColors.black), label: ''),
      ],
      selectedItemColor: AppColors.primaryPurple,
      unselectedItemColor: AppColors.black,
    );
  }
}