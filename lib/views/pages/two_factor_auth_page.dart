import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  bool _is2FAEnabled = false;
  bool _isLoading = false;

  void _toggle2FA(bool value) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _is2FAEnabled = value;
      _isLoading = false;
    });

    if (value) {
      _showSetupDialog();
    }
  }

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
            onPressed: () => Navigator.pop(context),
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
            Navigator.pop(context);
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
              // 2FA Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppColors.getPrimaryColor(context),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Two-Factor Authentication',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
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
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Switch(
                        value: _is2FAEnabled,
                        onChanged: _toggle2FA,
                        activeColor: AppColors.getPrimaryColor(context),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Info Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem('1. Download an authenticator app like Google Authenticator'),
                    _buildInfoItem('2. Scan the QR code when prompted'),
                    _buildInfoItem('3. Enter the 6-digit code from the app'),
                    _buildInfoItem('4. Save your backup codes'),
                  ],
                ),
              ),

              const Spacer(),

              // Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _is2FAEnabled ? AppColors.success.withOpacity(0.1) : AppColors.getCardBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _is2FAEnabled ? AppColors.success : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _is2FAEnabled ? Icons.check_circle : Icons.info,
                      color: _is2FAEnabled ? AppColors.success : AppColors.getSecondaryTextColor(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _is2FAEnabled
                            ? 'Two-factor authentication is enabled'
                            : 'Two-factor authentication is disabled',
                        style: TextStyle(
                          color: _is2FAEnabled ? AppColors.success : AppColors.getSecondaryTextColor(context),
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

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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