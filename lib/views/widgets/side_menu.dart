import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/utils/text_components.dart';
import '/viewmodels/side_menu_viewmodel.dart';
import '/viewmodels/home_viewmodel.dart';

// SideMenu is a navigation drawer that provides main app navigation
// It displays user profile information and menu options
class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Access HomeViewModel to get user data (name, email, etc.)
    final homeViewModel = context.watch<HomeViewModel>();

    return ChangeNotifierProvider(
      // Create SideMenuViewModel with user data from HomeViewModel
      create: (_) => SideMenuViewModel(userName: homeViewModel.userName),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<SideMenuViewModel>(
            builder: (context, viewModel, child) {
              // Handle navigation when viewModel triggers route change
              if (viewModel.navigateToRoute != null) {
                // Use postFrameCallback to ensure navigation happens after build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context); // Close drawer first
                  Navigator.pushNamed(
                    context,
                    viewModel.navigateToRoute!,
                    arguments: viewModel.navigationArguments,
                  ).then((_) => viewModel.clearNavigation()); // Reset navigation state
                });
              }

              return Drawer(
                child: Container(
                  color: AppColors.getSideMenuBackground(context),
                  child: Column(
                    children: [
                      _buildHeaderSection(context, viewModel), // User profile section
                      _buildHeaderDivider(context), // Divider below header
                      _buildMenuItems(context, viewModel), // Navigation menu items
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Builds the header section with user profile information
  Widget _buildHeaderSection(BuildContext context, SideMenuViewModel viewModel) {
    return Container(
      height: 180, // Fixed height for header section
      decoration: BoxDecoration(
        color: AppColors.getSideMenuBackground(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Ample top padding for status bar
        child: Row(
          children: [
            // Profile avatar container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLightPurple.withOpacity(0.2), // Subtle purple background
              ),
              child: viewModel.photoUrl != null
                  ? ClipOval(
                child: Image.network(
                  viewModel.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    color: AppColors.getSideMenuIcon(context),
                    size: 40,
                  ), // Fallback icon if image fails to load
                ),
              )
                  : Icon(
                Icons.person, // Default person icon
                color: AppColors.getSideMenuIcon(context),
                size: 40,
              ),
            ),
            const SizedBox(width: 12), // Spacing between avatar and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User greeting with name
                  Text(
                    TextComponents.userGreeting(viewModel.userNameDisplay),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getSideMenuItemText(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                  // User email 
                  if (viewModel.userEmail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      viewModel.userEmail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getSideMenuItemText(context).withOpacity(0.7), // Subtle color
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Edit Profile button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(context),
                      borderRadius: BorderRadius.circular(20), // Pill-shaped button
                    ),
                    child: Material(
                      color: Colors.transparent, 
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => viewModel.onEditProfileTapped(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            TextComponents.menuEditProfile,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the divider below the header section
  Widget _buildHeaderDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: AppColors.getSideMenuDivider(context),
        thickness: 1,
        height: 1,
      ),
    );
  }

  // Builds the scrollable list of menu items
  Widget _buildMenuItems(BuildContext context, SideMenuViewModel viewModel) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          // Generate menu items dynamically from viewModel
          ...viewModel.menuItems.map((item) => _buildMenuItem(
            context: context,
            viewModel: viewModel,
            text: item['text'],
            icon: item['icon'],
            route: item['route'],
          )),

          const SizedBox(height: 20), // Spacing before divider
          _buildDivider(context), // Divider between main menu and logout

          // Logout button 
          _buildMenuItem(
            context: context,
            viewModel: viewModel,
            text: TextComponents.menuLogout,
            icon: Icons.logout,
            route: '/logout',
            onTap: () async {
              Navigator.pop(context); // Close drawer first
              Navigator.pushNamed(context, '/logout'); // Navigate to logout flow
            },
          ),
        ],
      ),
    );
  }

  // Builds a divider line for menu sections
  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: AppColors.getSideMenuDivider(context),
        thickness: 1,
        height: 1,
      ),
    );
  }

  // Builds an individual menu item with icon and text
  Widget _buildMenuItem({
    required BuildContext context,
    required SideMenuViewModel viewModel,
    required String text,
    required IconData icon,
    String? route,
    VoidCallback? onTap, // Custom tap handler for special cases like logout
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Outer spacing
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.getSideMenuIcon(context),
          size: 24,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: AppColors.getSideMenuItemText(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap ?? () {
          // Use custom onTap if provided, otherwise use default route navigation
          if (route != null) {
            viewModel.onMenuItemTapped(route);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8), // Inner padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners for tap area
        ),
      ),
    );
  }
}
