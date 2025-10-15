import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ActiveSessionsPage extends StatefulWidget {
  const ActiveSessionsPage({super.key});

  @override
  State<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends State<ActiveSessionsPage> {
  final List<Session> _sessions = [
    Session(
      device: 'Honor 200 Pro',
      location: 'Cape Town, SA',
      lastActive: 'Current session',
      isCurrent: true,
    ),
    Session(
      device: 'Samsung S24 Ultra',
      location: 'Cape Town, SA',
      lastActive: '2 hours ago',
      isCurrent: false,
    ),
    Session(
      device: 'Samsung A55 5G',
      location: 'Johannesburg, SA',
      lastActive: '4 hours ago',
      isCurrent: false,
    ),
  ];

  void _logoutAllOtherSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCardBackground(context),
        title: Text(
          'Logout All Other Sessions',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will log you out from all other devices except this one.',
          style: TextStyle(
            color: AppColors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sessions.removeWhere((session) => !session.isCurrent);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All other sessions have been logged out'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Logout All',
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

  void _logoutSession(Session session) {
    setState(() {
      _sessions.remove(session);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out from ${session.device}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Active Sessions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Logout All Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _logoutAllOtherSessions,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout All Other Sessions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Sessions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return _buildSessionItem(session);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(Session session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            session.device.contains('iPhone') || session.device.contains('Samsung')
                ? Icons.phone_iphone
                : Icons.laptop,
            color: AppColors.getPrimaryColor(context),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      session.device,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    if (session.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.location,
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.lastActive,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          if (!session.isCurrent) ...[
            IconButton(
              onPressed: () => _logoutSession(session),
              icon: Icon(
                Icons.logout,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Session {
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;

  Session({
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });
}