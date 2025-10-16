// TODO: Currently AccountHubViewModel reads data from local storage (SharedPreferences).
//       Once backend is implemented, consider reading from EditProfileViewModel or
//       a centralized state to avoid desyncs and to reflect changes instantly.


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
import '../../viewmodels/profile_page_viewmodel.dart';
import 'edit_profile_page.dart';
import 'help_page.dart';
import 'guides_page.dart';

class AccountHubPage extends StatefulWidget {
  const AccountHubPage({super.key});

  @override
  State<AccountHubPage> createState() => _AccountHubPageState();
}

class _AccountHubPageState extends State<AccountHubPage> {
  late AccountHubViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AccountHubViewModel();
    _viewModel.loadUserData();
  }

  /// Whenever we return to this page from another (like Edit Profile),
  /// we refresh user data to reflect any updates.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel.refreshUserData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AccountHubViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 3,
              title: Text(
                "Account Hub",
                style: GoogleFonts.inter(
                  color: AppColors.primaryDarkBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.primaryDarkBlue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  ProfilePic(viewModel: viewModel),
                  const SizedBox(height: 30),

                  // MENU OPTIONS
                  ProfileMenu(
                    text: "Edit Profile",
                    icon: "assets/icons/User Icon.svg",
                    press: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );

                      // Refresh data after returning
                      await viewModel.refreshUserData();
                    },
                  ),
                  ProfileMenu(
                    text: "Settings",
                    icon: "assets/icons/Settings.svg",
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const SettingsPagePlaceholder(),
                      ),
                    ),
                  ),
                  ProfileMenu(
                    text: "Help Center",
                    icon: "assets/icons/Question mark.svg",
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpPage(),
                      ),
                    ),
                  ),
                  ProfileMenu(
                    text: "Privacy Policy",
                    icon: "assets/icons/Lock.svg",
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const PrivacyPolicyPagePlaceholder(),
                      ),
                    ),
                  ),
                  ProfileMenu(
                    text: "Log Out",
                    icon: "assets/icons/Log out.svg",
                    press: () => _showLogoutDialog(context, viewModel),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AccountHubViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.primaryDarkBlue),
            ),
          ),
          TextButton(
            onPressed: () async {
              await viewModel.logout();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Logged out successfully!',
                      style: GoogleFonts.inter(),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(color: AppColors.primaryDarkBlue),
            ),
          ),
        ],
      ),
    );
  }
}

//
// PROFILE PIC
//
class ProfilePic extends StatelessWidget {
  final AccountHubViewModel viewModel;

  const ProfilePic({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 57.5,
          backgroundColor: AppColors.white,
          // TODO: Once you implement a real backend, you’ll want to fetch
          // fresh profile image from the server or listen to EditProfileViewModel.
          backgroundImage: NetworkImage(viewModel.profileImageUrl),
        ),
        const SizedBox(height: 12),
        Text(
          viewModel.userName,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDarkBlue,
          ),
        ),
      ],
    );
  }
}

//
// PROFILE MENU
//
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.icon,
    this.press,
  });

  final String text, icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDarkBlue,
          padding: const EdgeInsets.all(20),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                AppColors.primaryDarkBlue,
                BlendMode.srcIn,
              ),
              width: 22,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: AppColors.primaryDarkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryDarkBlue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

//
// PLACEHOLDERS
//
class SettingsPagePlaceholder extends StatelessWidget {
  const SettingsPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(
        child: Text('Settings Page - Coming Soon!'),
      ),
    );
  }
}

class PrivacyPolicyPagePlaceholder extends StatelessWidget {
  const PrivacyPolicyPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(
        child: Text('Privacy Policy Page - Coming Soon!'),
      ),
    );
  }
}
