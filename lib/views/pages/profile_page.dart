import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Roomantics/views/pages/privacy_policy_page.dart';
import '../../viewmodels/profile_page_viewmodel.dart';
import '/utils/colors.dart';
import '/views/pages/edit_profile_page.dart';
import '/views/pages/help_page.dart';
import '/views/pages/settings_page.dart';

class AccountHubPage extends StatefulWidget {
  const AccountHubPage({super.key});

  @override
  State<AccountHubPage> createState() => _AccountHubPageState();
}

class _AccountHubPageState extends State<AccountHubPage> with WidgetsBindingObserver {
  late AccountHubViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AccountHubViewModel();
    WidgetsBinding.instance.addObserver(this);

    // Load user data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadUserData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  /// Listen for app state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      _viewModel.forceRefreshUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountHubViewModel>.value(
      value: _viewModel,
      child: Consumer<AccountHubViewModel>(
        builder: (context, viewModel, child) {
          // Handle navigation to other routes
          if (viewModel.navigateToRoute != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                viewModel.navigateToRoute!,
                    (route) => false,
              ).then((_) => viewModel.clearNavigation());
            });
          }

          // Handle messages (errors and success)
          _handleMessages(context, viewModel);
          return Scaffold(
            backgroundColor: AppColors.getBackgroundColor(context),
            appBar: AppBar(
              backgroundColor: AppColors.getAppBarBackground(context),
              elevation: 0,
              title: Text(
                "Account Hub",
                style: GoogleFonts.inter(
                  color: AppColors.getAppBarForeground(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.getAppBarForeground(context),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // Refresh button
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.getAppBarForeground(context),
                  ),
                  onPressed: () => viewModel.refreshUserData(),
                ),
                // Sync button
                IconButton(
                  icon: Icon(
                    Icons.sync,
                    color: AppColors.getAppBarForeground(context),
                  ),
                  onPressed: () => viewModel.syncWithBackend(),
                ),
              ],
            ),
            body: viewModel.isLoading
                ? _buildLoadingState(context)
                : RefreshIndicator(
              onRefresh: () => viewModel.refreshUserData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    _buildProfileHeader(context, viewModel),
                    const SizedBox(height: 20),

                    // User Statistics
                    _buildUserStatistics(context, viewModel),
                    const SizedBox(height: 30),

                    // Menu Options
                    _buildMenuItem(
                      context,
                      text: "Edit Profile",
                      icon: Icons.person_outline,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                        // Refresh after returning
                        await viewModel.refreshUserData();
                      },
                    ),

                    _buildMenuItem(
                      context,
                      text: "Settings",
                      icon: Icons.settings_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      ),
                    ),

                    _buildMenuItem(
                      context,
                      text: "Help Center",
                      icon: Icons.help_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      ),
                    ),

                    _buildMenuItem(
                      context,
                      text: "Privacy Policy",
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildMenuItem(
                      context,
                      text: "Log Out",
                      icon: Icons.logout,
                      isLogout: true,
                      onTap: () => viewModel.logout(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Handle error and success messages from viewmodel
  void _handleMessages(BuildContext context, AccountHubViewModel viewModel) {
    // Show error messages
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () => viewModel.clearError(),
              ),
            ),
          );
          viewModel.clearError();
        }
      });
    }

    // Show success messages
    if (viewModel.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          viewModel.clearSuccess();
        }
      });
    }
  }

  // Loading state with spinner
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.getPrimaryColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Profile header with image, name and email
  Widget _buildProfileHeader(BuildContext context, AccountHubViewModel viewModel) {
    return Column(
      children: [
        // Profile Image with cache busting
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.getPrimaryColor(context),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: viewModel.profileImageUrlWithCacheBusting != null
                ? Image.network(
              viewModel.profileImageUrlWithCacheBusting!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildProfilePlaceholder(context),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildProfilePlaceholder(context);
              },
            )
                : _buildProfilePlaceholder(context),
          ),
        ),

        const SizedBox(height: 16),

        // User Name
        Text(
          viewModel.userName,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextColor(context),
          ),
        ),

        const SizedBox(height: 4),

        // Email
        Text(
          viewModel.email,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  // User statistics section with projects, designs and favorites
  Widget _buildUserStatistics(BuildContext context, AccountHubViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              count: viewModel.projectsCount,
              label: 'Projects',
              icon: Icons.work_outline,
            ),
            _buildStatItem(
              context,
              count: viewModel.designsCount,
              label: 'Designs',
              icon: Icons.design_services,
            ),
            _buildStatItem(
              context,
              count: viewModel.favoritesCount,
              label: 'Favorites',
              icon: Icons.favorite_outline,
            ),
          ],
        ),
      ),
    );
  }

  // Individual statistic item with icon, count and label
  Widget _buildStatItem(BuildContext context, {
    required int count,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.getPrimaryColor(context).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.getPrimaryColor(context),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  // Placeholder when profile image is not available
  Widget _buildProfilePlaceholder(BuildContext context) {
    return Container(
      color: AppColors.getPrimaryColor(context).withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColors.getPrimaryColor(context),
      ),
    );
  }

  // Menu item builder for navigation options
  Widget _buildMenuItem(
      BuildContext context, {
        required String text,
        required IconData icon,
        required VoidCallback onTap,
        bool isLogout = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLogout
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.getPrimaryColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout
                        ? AppColors.error
                        : AppColors.getPrimaryColor(context),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      color: isLogout
                          ? AppColors.error
                          : AppColors.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.getSecondaryTextColor(context),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
