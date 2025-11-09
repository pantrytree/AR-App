import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  bool _is2FAEnabled = false; // Tracks whether 2FA is enabled or disabled
  bool _isLoading = false; // Shows loading state during toggle operations

  // Handles the toggle switch for enabling/disabling 2FA
  void _toggle2FA(bool value) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Simulate API call to backend for enabling/disabling 2FA
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _is2FAEnabled = value; // Update 2FA status
      _isLoading = false; // Hide loading indicator
    });

    // Show setup confirmation dialog when enabling 2FA
    if (value) {
      _showSetupDialog();
    }
  }

  // Shows a confirmation dialog when 2FA is successfully enabled
  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Setup Complete',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Two-factor authentication has been enabled. You will need to enter a verification code each time you sign in.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close the dialog
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.getPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Navigator.pop(context); // Navigate back to previous screen
          },
        ),
        centerTitle: true,
        title: Text(
          'Two-Factor Authentication',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Main 2FA Toggle Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Security icon
                    Icon(
                      Icons.security,
                      color: AppColors.getPrimaryColor(context),
                      size: 24,
                    ),
                    const SizedBox(width: 16), // Spacing between icon and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Two-Factor Authentication',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Description
                          Text(
                            'Add an extra layer of security to your account',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Loading indicator or toggle switch
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2), // Show loading during API call
                      )
                    else
                      Switch(
                        value: _is2FAEnabled,
                        onChanged: _toggle2FA, // Call toggle function when switch is changed
                        activeColor: AppColors.getPrimaryColor(context), // Custom color for enabled state
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Spacing between sections

              // Information Section - How 2FA Works
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Step-by-step instructions
                    _buildInfoItem('1. Download an authenticator app like Google Authenticator'),
                    _buildInfoItem('2. Scan the QR code when prompted'),
                    _buildInfoItem('3. Enter the 6-digit code from the app'),
                    _buildInfoItem('4. Save your backup codes'),
                  ],
                ),
              ),

              const Spacer(), // Pushes the status section to the bottom

              // Status Display Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _is2FAEnabled 
                      ? AppColors.success.withOpacity(0.1) // Green background when enabled
                      : AppColors.getCardBackground(context), // Normal background when disabled
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _is2FAEnabled 
                        ? AppColors.success // Green border when enabled
                        : Colors.transparent, // No border when disabled
                  ),
                ),
                child: Row(
                  children: [
                    // Status icon
                    Icon(
                      _is2FAEnabled ? Icons.check_circle : Icons.info,
                      color: _is2FAEnabled 
                          ? AppColors.success // Green check when enabled
                          : AppColors.getSecondaryTextColor(context), // Grey info when disabled
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _is2FAEnabled
                            ? 'Two-factor authentication is enabled' // Enabled message
                            : 'Two-factor authentication is disabled', // Disabled message
                        style: TextStyle(
                          color: _is2FAEnabled 
                              ? AppColors.success // Green text when enabled
                              : AppColors.getSecondaryTextColor(context), // Grey text when disabled
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent info list items
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet point
          Text(
            '• ',
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
