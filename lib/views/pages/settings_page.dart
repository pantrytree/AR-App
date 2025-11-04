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
  late SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();

    // Clear any previous navigation when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.clearNavigation();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ChangeNotifierProvider<SettingsViewModel>.value(
          value: _viewModel,
          child: Consumer<SettingsViewModel>(
            builder: (context, settingsViewModel, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (settingsViewModel.navigateToRoute != null) {
                  final route = settingsViewModel.navigateToRoute;
                  settingsViewModel.clearNavigation();

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
                body: RefreshIndicator(
                  onRefresh: () => settingsViewModel.refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (settingsViewModel.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
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
                                    settingsViewModel.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => settingsViewModel.clearMessages(),
                                ),
                              ],
                            ),
                          ),

                        if (settingsViewModel.successMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
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
                                    settingsViewModel.successMessage!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => settingsViewModel.clearMessages(),
                                ),
                              ],
                            ),
                          ),

                        _buildUserSection(context, settingsViewModel),
                        const SizedBox(height: 20),
                        _buildGeneralSection(context, themeManager, settingsViewModel),
                        const SizedBox(height: 20),
                        _buildAccountSecuritySection(context, settingsViewModel),
                        const SizedBox(height: 20),
                        _buildOtherOptionsSection(context, settingsViewModel),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
                image: settingsViewModel.photoUrl != null
                    ? DecorationImage(
                  image: NetworkImage(settingsViewModel.photoUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: settingsViewModel.photoUrl == null
                  ? Icon(
                Icons.person,
                color: AppColors.getPrimaryColor(context),
                size: 20,
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settingsViewModel.userName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settingsViewModel.userEmail,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              _showClearCacheDialog(context, settingsViewModel);
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

  void _showClearCacheDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<String>(
        future: settingsViewModel.getCacheSize(),
        builder: (context, snapshot) {
          final cacheSize = snapshot.data ?? 'Calculating...';

          return AlertDialog(
            backgroundColor: AppColors.getCardBackground(context),
            title: Text(
              'Clear Cache',
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
                  'This will free up storage space by clearing cached data.',
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current cache size: $cacheSize',
                  style: TextStyle(
                    color: AppColors.getPrimaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (loadingContext) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final success = await settingsViewModel.clearCache();

                  // Hide loading
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache cleared successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Text(
                  'Clear Cache',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final success = await settingsViewModel.deleteAccount();

              // Hide loading
              if (context.mounted) {
                Navigator.pop(context);
              }

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted successfully'),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 2),
                  ),
                );

                await Future.delayed(const Duration(seconds: 1));

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false,
                  );
                }
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(settingsViewModel.errorMessage ?? 'Failed to delete account'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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