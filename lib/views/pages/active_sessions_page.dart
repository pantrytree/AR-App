import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../services/session_service.dart';
import '../../utils/colors.dart';

// Page displaying active user sessions across different devices
// Allows users to monitor and manage their logged-in sessions
class ActiveSessionsPage extends StatefulWidget {
  const ActiveSessionsPage({super.key});

  @override
  State<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends State<ActiveSessionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Session> _sessions = [];           // List of active user sessions
  bool _isLoading = true;                 // Loading state indicator
  String? _error;                         // Error message storage
  StreamSubscription? _sessionsSubscription; // Firestore listener subscription
  String? _currentSessionId;              // ID of current device session

  @override
  void initState() {
    super.initState();
    _getCurrentSessionId().then((_) {
      _subscribeToSessions(); // Start listening to session updates
    });
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel(); // Clean up subscription
    super.dispose();
  }

  // Generates and stores the current device's session ID
  Future<void> _getCurrentSessionId() async {
    final sessionService = SessionService();
    _currentSessionId = await sessionService.generateSessionId();
  }

  // Subscribes to real-time updates of user's active sessions
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
        .where('isActive', isEqualTo: true) // Only active sessions
        .orderBy('lastActive', descending: true) // Most recent first
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

  // Converts Firestore documents into Session objects
  void _processSessions(List<DocumentSnapshot> docs) {
    _sessions = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Session(
        id: doc.id,
        device: data['deviceName'] as String? ?? 'Unknown Device',
        model: data['model'] as String? ?? 'Unknown Model',
        manufacturer: data['manufacturer'] as String? ?? 'Unknown',
        location: data['location'] as String? ?? 'Unknown Location',
        lastActive: _formatLastActive(data['lastActive'] as Timestamp?),
        isCurrent: doc.id == _currentSessionId, // Mark current device session
        platform: data['platform'] as String? ?? 'Unknown',
        ipAddress: data['ipAddress'] as String? ?? 'Unknown',
        userAgent: data['userAgent'] as String? ?? '',
        osVersion: data['osVersion'] as String? ?? 'Unknown',
        appVersion: data['appVersion'] as String? ?? 'Unknown',
        createdAt: data['createdAt'] as Timestamp?,
      );
    }).toList();

    setState(() {
      _isLoading = false;
    });
  }

  // Formats timestamp 
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

  // Shows confirmation dialog for logging out all other sessions
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

  // Performs the actual logout of all sessions except current one
  Future<void> _performLogoutAllOtherSessions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final currentSessionId = _currentSessionId;

      // Get all sessions except current one
      final sessionsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();

      for (final doc in sessionsSnapshot.docs) {
        if (doc.id != currentSessionId) {
          batch.update(doc.reference, {
            'isActive': false, // Mark as inactive
            'endedAt': FieldValue.serverTimestamp(), // Record end time
          });
        }
      }

      await batch.commit(); // Execute all updates in single batch

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

  // Logs out a specific session
  Future<void> _logoutSession(Session session) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .doc(session.id)
          .update({
        'isActive': false,
        'endedAt': FieldValue.serverTimestamp(),
      });

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

  // Manually refreshes the sessions list
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
          .where('isActive', isEqualTo: true)
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
            onPressed: _refreshSessions, // Manual refresh button
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Logout All Button - Only show if multiple sessions exist
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

  // Builds individual session list item with device information
  Widget _buildSessionItem(Session session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: session.isCurrent
            ? Border.all(color: AppColors.primaryPurple, width: 2) // Highlight current session
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getDeviceIcon(session.platform),
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
                      '${session.manufacturer} ${session.model}',
                      style: TextStyle(
                        color: AppColors.getSecondaryTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!session.isCurrent)
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
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 4),
          Text(
            'IP: ${session.ipAddress}',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'OS: ${session.osVersion} | App: ${session.appVersion}',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Returns appropriate icon based on device platform
  IconData _getDeviceIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.laptop_windows;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.devices_other;
    }
  }
}

// Data model representing a user session on a specific device
class Session {
  final String id;
  final String device;
  final String model;
  final String manufacturer;
  final String location;
  final String lastActive;
  final bool isCurrent;
  final String platform;
  final String ipAddress;
  final String userAgent;
  final String osVersion;
  final String appVersion;
  final Timestamp? createdAt;

  Session({
    required this.id,
    required this.device,
    required this.model,
    required this.manufacturer,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
    required this.platform,
    required this.ipAddress,
    required this.userAgent,
    required this.osVersion,
    required this.appVersion,
    this.createdAt,
  });
}
