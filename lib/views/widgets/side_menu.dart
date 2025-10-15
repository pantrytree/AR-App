import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/utils/text_components.dart';
import '../pages/help_page.dart';
import '../pages/my_likes_page.dart';
import '../pages/my_projects_page.dart';
import '../pages/edit_profile_page.dart';
import '../pages/catalogue_page.dart';
import '../pages/settings_page.dart';

class SideMenu extends StatelessWidget {
  final String? userName;

  const SideMenu({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Drawer(
          child: Container(
            color: AppColors.getSideMenuBackground(context),
            child: Column(
              children: [
                _buildHeaderSection(context),
                _buildHeaderDivider(context), // Divider between header and menus
                _buildMenuItems(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.getSideMenuBackground(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Row(
          children: [
            // Profile icon - no background, just the icon
            Icon(
              Icons.person,
              color: AppColors.getSideMenuIcon(context), // Dynamic icon color
              size: 60,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TextComponents.userGreeting(userName),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getSideMenuItemText(context), // Dynamic text color
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Edit Profile as oval button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.getPrimaryColor(context), // Dynamic primary color
                      borderRadius: BorderRadius.circular(20), // Oval shape
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pushNamed(context, "/edit_profile"),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            TextComponents.menuEditProfile,
                            style: TextStyle(
                              color: AppColors.white, // White text for contrast
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

  Widget _buildMenuItems(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          _buildMenuItem(
            context: context,
            text: TextComponents.menuCatalogue,
            icon: Icons.shopping_bag_outlined,
            route: "/catalogue",
          ),
          _buildMenuItem(
            context: context,
            text: TextComponents.menuLikes,
            icon: Icons.favorite_outline,
            route: "/likes",
          ),
          _buildMenuItem(
            context: context,
            text: TextComponents.menuProjects,
            icon: Icons.work_outline,
            route: "/projects",
          ),
          _buildMenuItem(
            context: context,
            text: TextComponents.menuSettings,
            icon: Icons.settings_outlined,
            route: "/settings",
          ),
          _buildMenuItem(
            context: context,
            text: TextComponents.menuHelp,
            icon: Icons.help_outline,
            route: "/help",
          ),
          _buildMenuItem(
            context: context,
            text: TextComponents.menuForgotPassword,
            icon: Icons.lock_reset,
            route: "/forgot_password",
          ),
          const SizedBox(height: 20),
          _buildDivider(context),
          _buildMenuItem(
            context: context,
            text: TextComponents.menuLogout,
            icon: Icons.logout,
            route: "/logout",
          ),
        ],
      ),
    );
  }

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

  Widget _buildMenuItem({
    required BuildContext context,
    required String text,
    required IconData icon,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.getSideMenuIcon(context), // Dynamic icon color
          size: 24,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: AppColors.getSideMenuItemText(context), // Dynamic text color
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer first
          Navigator.pushNamed(context, route);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}