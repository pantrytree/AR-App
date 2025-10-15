import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _projectUpdates = true;
  bool _promotional = false;

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection(
              title: 'Notification Channels',
              children: [
                _buildNotificationSwitch(
                  title: 'Push Notifications',
                  subtitle: 'Receive app notifications',
                  value: _pushNotifications,
                  onChanged: (value) => setState(() => _pushNotifications = value),
                ),
                _buildNotificationSwitch(
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  value: _emailNotifications,
                  onChanged: (value) => setState(() => _emailNotifications = value),
                ),
                _buildNotificationSwitch(
                  title: 'SMS Notifications',
                  subtitle: 'Receive text message alerts',
                  value: _smsNotifications,
                  onChanged: (value) => setState(() => _smsNotifications = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildNotificationSection(
              title: 'Notification Types',
              children: [
                _buildNotificationSwitch(
                  title: 'Project Updates',
                  subtitle: 'Updates on your design projects',
                  value: _projectUpdates,
                  onChanged: (value) => setState(() => _projectUpdates = value),
                ),
                _buildNotificationSwitch(
                  title: 'Promotional Offers',
                  subtitle: 'Special deals and promotions',
                  value: _promotional,
                  onChanged: (value) => setState(() => _promotional = value),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save notification preferences
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings saved'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
  }

  Widget _buildNotificationSection({
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

  Widget _buildNotificationSwitch({
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