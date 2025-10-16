// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../theme/theme.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Clear any previous navigation when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
      settingsViewModel.clearNavigation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Consumer<SettingsViewModel>(
          builder: (context, settingsViewModel, child) {
            // Handle navigation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (settingsViewModel.navigateToRoute != null) {
                final route = settingsViewModel.navigateToRoute;
                settingsViewModel.clearNavigation();

                // Navigate to the route
                Navigator.pushNamed(context, route!);
              }
            });

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
                  TextComponents.settingsPageTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.getAppBarForeground(context),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👤 Account Hub Section with icon
                    _buildUserSection(context, settingsViewModel),

                    const SizedBox(height: 20),

                    // ⚙️ General Settings Section
                    _buildGeneralSection(context, themeManager, settingsViewModel),

                    const SizedBox(height: 20),

                    // 🔐 Account Security Section
                    _buildAccountSecuritySection(context, settingsViewModel),

                    const SizedBox(height: 20),

                    // ℹ️ Other Options Section
                    _buildOtherOptionsSection(context, settingsViewModel),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserSection(BuildContext context, SettingsViewModel settingsViewModel) {
    return GestureDetector(
      onTap: () {
        settingsViewModel.navigateToProfile();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.getPrimaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Hub', // Changed from 'User' to 'Account Hub'
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current User',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.getSecondaryTextColor(context),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context, ThemeManager themeManager, SettingsViewModel settingsViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),

          _buildSoftItem(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              settingsViewModel.navigateToLanguage();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enabled',
            onTap: () {
              settingsViewModel.navigateToNotifications();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.clear_all,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              _showClearCacheDialog(context);
            },
            showTrailing: false,
          ),

          _buildSoftDivider(context),

          _buildSoftToggleItem(
            context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: themeManager.isDarkMode ? 'Enabled' : 'Disabled',
            value: themeManager.isDarkMode,
            onChanged: (value) {
              themeManager.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSecuritySection(BuildContext context, SettingsViewModel settingsViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Security',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),

          _buildSoftItem(
            context,
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              settingsViewModel.navigateToChangePassword();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Add extra security',
            onTap: () {
              settingsViewModel.navigateToTwoFactorAuth();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.devices,
            title: 'Active Sessions',
            subtitle: 'Manage logged-in devices',
            onTap: () {
              settingsViewModel.navigateToActiveSessions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtherOptionsSection(BuildContext context, SettingsViewModel settingsViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSoftItem(
            context,
            icon: Icons.info,
            title: 'About Application',
            subtitle: 'App version and info',
            onTap: () {
              settingsViewModel.navigateToAbout();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.help,
            title: 'Help/FAQ',
            subtitle: 'Get help and support',
            onTap: () {
              settingsViewModel.navigateToHelp();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              settingsViewModel.navigateToPrivacyPolicy();
            },
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'App usage terms',
            onTap: () {
              settingsViewModel.navigateToTermsOfService();
            },
          ),

          _buildSoftDivider(context),

          // Restructured Logout Button
          _buildSoftItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              settingsViewModel.navigateToLogout();
            },
            isLogout: true,
          ),

          _buildSoftDivider(context),

          // Delete Account option
          _buildSoftItem(
            context,
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account',
            onTap: () {
              _showDeleteAccountDialog(context, settingsViewModel);
            },
            isDelete: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSoftItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool showTrailing = true,
        bool isLogout = false,
        bool isDelete = false,
      }) {
    Color primaryColor = AppColors.getPrimaryColor(context);

    if (isLogout) {
      primaryColor = AppColors.primaryPurple;
    } else if (isDelete) {
      primaryColor = AppColors.error;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: primaryColor,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.getTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.getSecondaryTextColor(context),
        ),
      ),
      trailing: showTrailing
          ? Icon(
        Icons.arrow_forward_ios,
        color: AppColors.getSecondaryTextColor(context),
        size: 14,
      )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      minLeadingWidth: 32,
      dense: true,
    );
  }

  Widget _buildSoftToggleItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required Function(bool) onChanged,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.getPrimaryColor(context),
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.getTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.getSecondaryTextColor(context),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.getPrimaryColor(context),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      minLeadingWidth: 32,
      dense: true,
    );
  }

  Widget _buildSoftDivider(BuildContext context) {
    return Divider(
      height: 16,
      thickness: 0.5,
      color: AppColors.getSecondaryTextColor(context).withOpacity(0.1),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Clear Cache',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will free up storage space by clearing cached data.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your delete account logic here
              // settingsViewModel.deleteAccount();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account successfully deleted!'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}