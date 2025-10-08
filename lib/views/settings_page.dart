import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: const _SettingsPageBody(),
    );
  }
}

class _SettingsPageBody extends StatelessWidget {
  const _SettingsPageBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      backgroundColor: viewModel.isDarkMode ? Colors.grey[900] : const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: viewModel.isDarkMode ? Colors.grey[900] : const Color(0xFFF7F6FF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: viewModel.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: viewModel.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileCard(viewModel),
            const SizedBox(height: 30),
            Text(
              'General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: viewModel.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _settingsGroup(viewModel, [
              _settingsItem(viewModel, Icons.language, 'Language'),
              _settingsItem(viewModel, Icons.notifications_none_rounded, 'Notifications'),
              _settingsItem(viewModel, Icons.delete_outline_rounded, 'Clear cache'),
              _settingsSwitch(
                  viewModel, Icons.dark_mode_outlined, 'Dark mode', viewModel.isDarkMode,
                      (val) => viewModel.toggleDarkMode(val)),
            ]),
            const SizedBox(height: 30),
            _settingsGroup(viewModel, [
              _settingsItem(viewModel, Icons.info_outline_rounded, 'About application'),
              _settingsItem(viewModel, Icons.help_outline_rounded, 'Help/FAQ'),
              _settingsItem(viewModel, Icons.power_settings_new_rounded, 'Logout', color: Colors.red),
            ]),
          ],
        ),
      ),
    );
  }

  // 🧱 Helper widgets
  Widget _profileCard(SettingsViewModel viewModel) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: viewModel.isDarkMode ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFFB48CF2),
          child: Icon(Icons.person, size: 35, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Text(
          'User',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: viewModel.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        Icon(Icons.arrow_forward_ios_rounded,
            color: viewModel.isDarkMode ? Colors.white70 : Colors.grey),
      ],
    ),
  );

  Widget _settingsGroup(SettingsViewModel viewModel, List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: viewModel.isDarkMode ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _settingsItem(SettingsViewModel viewModel, IconData icon, String title,
      {Color? color}) =>
      ListTile(
        leading: Icon(icon,
            color: color ??
                (viewModel.isDarkMode ? Colors.white : Colors.black),
            size: 28),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? (viewModel.isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: viewModel.isDarkMode ? Colors.white70 : Colors.grey, size: 18),
        onTap: () {},
      );

  Widget _settingsSwitch(SettingsViewModel viewModel, IconData icon, String title,
      bool value, Function(bool) onChanged) =>
      SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon,
            color: viewModel.isDarkMode ? Colors.white : Colors.black, size: 28),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: viewModel.isDarkMode ? Colors.white : Colors.black)),
      );
}
