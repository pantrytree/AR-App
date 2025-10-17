import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/colors.dart';

class ActiveSessionsPage extends StatefulWidget {
  const ActiveSessionsPage({super.key});

  @override
  State<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends State<ActiveSessionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Session> _sessions = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _sessionsSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToSessions();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToSessions() {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'User not authenticated';
      });
      return;
    }

    _sessionsSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .orderBy('lastActive', descending: true)
        .snapshots()
        .listen((snapshot) {
      _processSessions(snapshot.docs);
    }, onError: (error) {
      setState(() {
        _error = 'Failed to load sessions: $error';
        _isLoading = false;
      });
    });
  }

  void _processSessions(List<DocumentSnapshot> docs) {
    final currentSessionId = _getCurrentSessionId();

    _sessions = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Session(
        id: doc.id,
        device: data['deviceName'] as String? ?? 'Unknown Device',
        location: data['location'] as String? ?? 'Unknown Location',
        lastActive: _formatLastActive(data['lastActive'] as Timestamp?),
        isCurrent: doc.id == currentSessionId,
        platform: data['platform'] as String? ?? 'Unknown',
        ipAddress: data['ipAddress'] as String? ?? '',
        userAgent: data['userAgent'] as String? ?? '',
        createdAt: data['createdAt'] as Timestamp?,
      );
    }).toList();

    setState(() {
      _isLoading = false;
    });
  }

  String _getCurrentSessionId() {
    // Use a combination of device ID and user ID for current session
    // In a real app, you'd use device_info_plus package
    return 'current_session_${_auth.currentUser?.uid}';
  }

  String _formatLastActive(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';

    final now = DateTime.now();
    final lastActive = timestamp.toDate();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${lastActive.day}/${lastActive.month}/${lastActive.year}';
  }

  Future<void> _logoutAllOtherSessions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

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
            'This will log you out from all other devices except this one. You will need to sign in again on those devices.',
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
              onPressed: () async {
                Navigator.pop(context);
                await _performLogoutAllOtherSessions();
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _performLogoutAllOtherSessions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final currentSessionId = _getCurrentSessionId();

      // Get all sessions except current one
      final sessionsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .get();

      final batch = _firestore.batch();

      for (final doc in sessionsSnapshot.docs) {
        if (doc.id != currentSessionId) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All other sessions have been logged out'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout other sessions: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _logoutSession(Session session) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .doc(session.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out from ${session.device}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _refreshSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .orderBy('lastActive', descending: true)
          .get();

      _processSessions(snapshot.docs);
    } catch (e) {
      setState(() {
        _error = 'Failed to refresh sessions: $e';
        _isLoading = false;
      });
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Active Sessions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.getAppBarForeground(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.getAppBarForeground(context),
            ),
            onPressed: _refreshSessions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Logout All Button
            if (_sessions.length > 1)
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

            // Loading/Error State
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshSessions,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_sessions.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices,
                          size: 64,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active sessions',
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your active sessions will appear here',
                          style: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
        border: session.isCurrent
            ? Border.all(color: AppColors.primaryPurple, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            _getDeviceIcon(session.device, session.platform),
            color: session.isCurrent
                ? AppColors.primaryPurple
                : AppColors.getPrimaryColor(context),
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
                  'Last active: ${session.lastActive}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
                if (session.ipAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'IP: ${session.ipAddress}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
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
              tooltip: 'Logout this device',
            ),
          ],
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String device, String platform) {
    if (platform.toLowerCase().contains('android') ||
        device.toLowerCase().contains('samsung') ||
        device.toLowerCase().contains('android')) {
      return Icons.android;
    } else if (platform.toLowerCase().contains('ios') ||
        device.toLowerCase().contains('iphone') ||
        device.toLowerCase().contains('ipad')) {
      return Icons.phone_iphone;
    } else if (device.toLowerCase().contains('laptop') ||
        device.toLowerCase().contains('mac') ||
        device.toLowerCase().contains('desktop')) {
      return Icons.laptop;
    } else if (device.toLowerCase().contains('tablet')) {
      return Icons.tablet;
    }
    return Icons.devices_other;
  }
}

class Session {
  final String id;
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;
  final String platform;
  final String ipAddress;
  final String userAgent;
  final Timestamp? createdAt;

  Session({
    required this.id,
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
    required this.platform,
    required this.ipAddress,
    required this.userAgent,
    this.createdAt,
  });
}