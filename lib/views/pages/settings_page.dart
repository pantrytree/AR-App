// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../utils/theme.dart';
import '../../utils/colors.dart';
import '../../utils/text_components.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🎨 SettingsPage building...');
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        print('🎨 ThemeManager state: ${themeManager.isDarkMode ? 'DARK' : 'LIGHT'}');
        return Consumer<SettingsViewModel>(
          builder: (context, settingsViewModel, child) {
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
                    // 👤 User Section with icon
                    _buildUserSection(context, settingsViewModel),

                    const SizedBox(height: 20),

                    // ⚙️ General Settings Section
                    _buildGeneralSection(context, themeManager, settingsViewModel),

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
              color: AppColors.getSecondaryTextColor(context).withOpacity(0.1),
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
                    'User',
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
            color: AppColors.getSecondaryTextColor(context).withOpacity(0.1),
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

  Widget _buildOtherOptionsSection(BuildContext context, SettingsViewModel settingsViewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.getSecondaryTextColor(context).withOpacity(0.1),
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

          // DELETE ACCOUNT OPTION
          _buildSoftItem(
            context,
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account',
            onTap: () {
              _showDeleteAccountDialog(context);
            },
            isDeleteAccount: true,
            showTrailing: false,
          ),

          _buildSoftDivider(context),

          _buildSoftItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              _showLogoutDialog(context);
            },
            isLogout: true,
            showTrailing: false,
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
        bool isDeleteAccount = false,
      }) {
    Color iconColor = AppColors.getPrimaryColor(context);
    Color textColor = AppColors.getTextColor(context);

    if (isLogout) {
      iconColor = AppColors.error;
      textColor = AppColors.error;
    } else if (isDeleteAccount) {
      iconColor = AppColors.warning;
      textColor = AppColors.warning;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Logout',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
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
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Logout',
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

  void _showDeleteAccountDialog(BuildContext context) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. This will permanently:',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• Delete your account and all personal data',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontSize: 13,
              ),
            ),
            Text(
              '• Remove all your saved projects and favorites',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontSize: 13,
              ),
            ),
            Text(
              '• Cancel any active subscriptions',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontSize: 13,
              ),
            ),
          ],
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
              _showFinalDeleteConfirmation(context);
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Final Confirmation',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Type "DELETE" to confirm account deletion:',
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
                SnackBar(
                  content: const Text('Account deletion requested'),
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 3),
                ),
              );
              // TODO: Implement actual account deletion API call
            },
            child: Text(
              'Delete Account',
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