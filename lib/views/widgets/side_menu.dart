import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/colors.dart';
import '../../theme/theme.dart';
import '/utils/text_components.dart';
import '/viewmodels/side_menu_viewmodel.dart';
import '/viewmodels/home_viewmodel.dart';

//Side Menu 
class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user name from HomeViewModel if available
    final homeViewModel = context.watch<HomeViewModel>();

    return ChangeNotifierProvider(
      create: (_) => SideMenuViewModel(userName: homeViewModel.userName),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Consumer<SideMenuViewModel>(
            builder: (context, viewModel, child) {
              // Handle navigation
              if (viewModel.navigateToRoute != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushNamed(
                    context,
                    viewModel.navigateToRoute!,
                    arguments: viewModel.navigationArguments,
                  ).then((_) => viewModel.clearNavigation());
                });
              }

              return Drawer(
                child: Container(
                  color: AppColors.getSideMenuBackground(context),
                  child: Column(
                    children: [
                      _buildHeaderSection(context, viewModel),
                      _buildHeaderDivider(context),
                      _buildMenuItems(context, viewModel),
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

  // Header section build
  Widget _buildHeaderSection(BuildContext context, SideMenuViewModel viewModel) {
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
            // Profile image or icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLightPurple.withOpacity(0.2),
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
                  ),
                ),
              )
                  : Icon(
                Icons.person,
                color: AppColors.getSideMenuIcon(context),
                size: 40,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TextComponents.userGreeting(viewModel.userNameDisplay),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getSideMenuItemText(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (viewModel.userEmail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      viewModel.userEmail!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getSideMenuItemText(context).withOpacity(0.7),
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
                      borderRadius: BorderRadius.circular(20),
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

  Widget _buildMenuItems(BuildContext context, SideMenuViewModel viewModel) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          // Dynamic menu items from viewModel
          ...viewModel.menuItems.map((item) => _buildMenuItem(
            context: context,
            viewModel: viewModel,
            text: item['text'],
            icon: item['icon'],
            route: item['route'],
          )),

          const SizedBox(height: 20),
          _buildDivider(context),

          // Logout button
          _buildMenuItem(
            context: context,
            viewModel: viewModel,
            text: TextComponents.menuLogout,
            icon: Icons.logout,
            route: '/logout',
            onTap: () async {
              Navigator.pop(context); // Close drawer first
              Navigator.pushNamed(context, '/logout');
            },
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
    required SideMenuViewModel viewModel,
    required String text,
    required IconData icon,
    String? route,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          if (route != null) {
            viewModel.onMenuItemTapped(route);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
