import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/utils/text_components.dart';

class SideMenu extends StatelessWidget {
  final String? userName;

  const SideMenu({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.sideMenuBackground,
        child: Column(
          children: [
            _buildHeaderSection(context),
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.sideMenuHeader,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.sideMenuIcon.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: AppColors.sideMenuIcon,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TextComponents.userGreeting,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/edit_profile"),
                    child: Text(
                      TextComponents.menuEditProfile,
                      style: TextStyle(
                        color: AppColors.sideMenuIcon,
                        fontSize: 14,
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
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuCatalogue,
              icon: Icons.shopping_bag_outlined,
              route: "/catalogue",
            ),
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuLikes,
              icon: Icons.favorite_outline,
              route: "/likes",
            ),
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuProjects,
              icon: Icons.work_outline,
              route: "/projects",
            ),
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuSettings,
              icon: Icons.settings_outlined,
              route: "/settings",
            ),
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuHelp,
              icon: Icons.help_outline,
              route: "/help",
            ),
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuForgotPassword,
              icon: Icons.lock_reset,
              route: "/forgot_password",
            ),
            _buildDivider(),
            _buildMenuItem(
              context: context,
              textId: TextComponents.menuLogout,
              icon: Icons.logout,
              route: "/logout",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Divider(
        color: AppColors.sideMenuDivider,
        thickness: 1,
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String textId,
    required IconData icon,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.sideMenuIcon,
            size: 24,
          ),
        ),
        title: Text(
          textId,
          style: TextStyle(
            color: AppColors.sideMenuItemText,
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