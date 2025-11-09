import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/change_password_viewmodel.dart';
import '../../utils/colors.dart';

// Page for users to change their account password with security validation
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true; // Toggle current password visibility
  bool _obscureNewPassword = true;     // Toggle new password visibility
  bool _obscureConfirmPassword = true; // Toggle confirm password visibility

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handles password change process with validation and security checks
  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<ChangePasswordViewModel>(context, listen: false);

      // Check if user is allowed to change password (rate limiting, etc.)
      final canChange = await viewModel.canChangePassword();
      if (!canChange['canChange']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(canChange['reason'] ?? 'Cannot change password at this time.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Attempt password change
      final success = await viewModel.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        // Send confirmation email/notification
        await viewModel.sendPasswordChangeConfirmation();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Return to previous screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppColors.getAppBarBackground(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.getAppBarForeground(context),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
            'Change Password',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getAppBarForeground(context),
            ),
          ),
        ),
        body: SafeArea(
          child: Consumer<ChangePasswordViewModel>(
            builder: (context, viewModel, child) {
              // Show error message from ViewModel if any exists
              if (viewModel.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  viewModel.clearError(); // Clear error after displaying
                });
              }

              // Show success message from ViewModel if any exists
              if (viewModel.successMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.successMessage!),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  viewModel.clearSuccess(); // Clear success after displaying
                });
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Security Information Banner
                      _buildSecurityInfo(context),
                      const SizedBox(height: 24),

                      // Current Password Input Field
                      _buildPasswordField(
                        context,
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // New Password Input Field
                      _buildPasswordField(
                        context,
                        label: 'New Password',
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return _validatePasswordStrength(value); // Password strength validation
                        },
                      ),
                      const SizedBox(height: 8),

                      // Visual Password Strength Indicator
                      _buildPasswordStrengthIndicator(_newPasswordController.text),
                      const SizedBox(height: 12),

                      // Confirm New Password Input Field
                      _buildPasswordField(
                        context,
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match'; // Match validation
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Change Password Button with Loading State
                      viewModel.isLoading
                          ? _buildLoadingButton()
                          : _buildSaveButton(context),

                      const SizedBox(height: 20),

                      // Password Requirements Information
                      _buildPasswordRequirements(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Builds security information banner about password change consequences
  Widget _buildSecurityInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.info, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For security, you will be logged out of other devices after changing your password.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.getTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds visual password strength indicator with progress bar
  Widget _buildPasswordStrengthIndicator(String password) {
    final strength = _calculatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Strength: ${strength['label']}',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: strength['color'],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength['value'],
          backgroundColor: AppColors.getSecondaryTextColor(context).withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(strength['color']),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  // Calculates password strength based on multiple criteria
  Map<String, dynamic> _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return {'label': 'None', 'value': 0.0, 'color': Colors.grey};
    }

    double strength = 0.0;

    // Length-based scoring
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // Character variety scoring
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2; // Uppercase
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2; // Lowercase
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2; // Numbers
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2; // Special chars

    // Determine strength level and corresponding color
    String label;
    Color color;

    if (strength < 0.4) {
      label = 'Weak';
      color = AppColors.error;
    } else if (strength < 0.7) {
      label = 'Fair';
      color = Colors.orange;
    } else if (strength < 0.9) {
      label = 'Good';
      color = Colors.blue;
    } else {
      label = 'Strong';
      color = AppColors.success;
    }

    return {'label': label, 'value': strength, 'color': color};
  }

  // Validates password meets security requirements
  String? _validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Include at least one special character';
    }
    return null;
  }

  // Builds reusable password input field with visibility toggle
  Widget _buildPasswordField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required bool obscureText,
        required VoidCallback onToggleVisibility,
        required String? Function(String?) validator,
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
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            onChanged: (value) {
              setState(() {}); // Rebuild to update strength indicator
            },
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
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.getSecondaryTextColor(context),
                ),
                onPressed: onToggleVisibility, // Toggle password visibility
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Builds loading state button during password change process
  Widget _buildLoadingButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: null, // Disabled during loading
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(context).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Changing Password...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Builds active save button for password change
  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getPrimaryColor(context),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Change Password',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Builds password requirements information card
  Widget _buildPasswordRequirements(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• At least 8 characters long\n• Include uppercase and lowercase letters\n• Include numbers and special characters\n• Not a commonly used password',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
