// lib/views/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../utils/colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationsViewModel(),
      child: const _NotificationsPageBody(),
    );
  }
}

class _NotificationsPageBody extends StatelessWidget {
  const _NotificationsPageBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
      builder: (context, viewModel, child) {
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
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Notification Settings',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.getAppBarForeground(context),
              ),
            ),
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show error message if any
                if (viewModel.errorMessage != null)
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
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Notification channels section
                _buildNotificationSection(
                  context: context,
                  title: 'Notification Channels',
                  children: [
                    _buildNotificationSwitch(
                      context: context,
                      title: 'Push Notifications',
                      subtitle: 'Receive app notifications',
                      value: viewModel.pushNotifications,
                      onChanged: viewModel.updatePushNotifications,
                    ),
                    _buildNotificationSwitch(
                      context: context,
                      title: 'Email Notifications',
                      subtitle: 'Receive updates via email',
                      value: viewModel.emailNotifications,
                      onChanged: viewModel.updateEmailNotifications,
                    ),
                    _buildNotificationSwitch(
                      context: context,
                      title: 'SMS Notifications',
                      subtitle: 'Receive text message alerts',
                      value: viewModel.smsNotifications,
                      onChanged: viewModel.updateSmsNotifications,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Notification types section
                _buildNotificationSection(
                  context: context,
                  title: 'Notification Types',
                  children: [
                    _buildNotificationSwitch(
                      context: context,
                      title: 'Project Updates',
                      subtitle: 'Updates on your design projects',
                      value: viewModel.projectUpdates,
                      onChanged: viewModel.updateProjectUpdates,
                    ),
                    _buildNotificationSwitch(
                      context: context,
                      title: 'Promotional Offers',
                      subtitle: 'Special deals and promotions',
                      value: viewModel.promotional,
                      onChanged: viewModel.updatePromotional,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Save settings button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      final success = await viewModel.saveNotificationSettings();

                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification settings saved'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                viewModel.errorMessage ?? 'Failed to save settings',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getPrimaryColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build section header with title
  Widget _buildNotificationSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  // Build individual notification switch item
  Widget _buildNotificationSwitch({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.getCardBackground(context),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.getTextColor(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.getPrimaryColor(context),
        ),
      ),
    );
  }
}
