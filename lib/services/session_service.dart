import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// Service for managing user sessions and tracking device/usage analytics
class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or update a user session with comprehensive device and location data
  Future<void> createOrUpdateSession({
    required String sessionId,
    String? deviceName,
    String? platform,
    String? location,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Collect comprehensive session information from various sources
      final deviceInfo = await _getDeviceInfo();
      final ipAddress = await _getIPAddress();
      final appVersion = await _getAppVersion();

      final sessionData = {
        'sessionId': sessionId,
        'userId': user.uid,
        'deviceName': deviceName ?? deviceInfo['deviceName'],
        'platform': platform ?? deviceInfo['platform'],
        'model': deviceInfo['model'],
        'manufacturer': deviceInfo['manufacturer'],
        'osVersion': deviceInfo['osVersion'],
        'appVersion': appVersion,
        'ipAddress': ipAddress,
        'userAgent': deviceInfo['userAgent'],
        'location': location ?? await _getLocationFromIP(ipAddress),
        'lastActive': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Store session data in user's sessions subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .doc(sessionId)
          .set(sessionData, SetOptions(merge: true));

      print('Session created/updated: $sessionId');
    } catch (e) {
      print('Error creating session: $e');
    }
  }

  // Collect detailed device information including model, OS, and manufacturer
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, String> deviceInfo = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceInfo = {
          'deviceName': androidInfo.device,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': 'Android ${androidInfo.version.release}',
          'platform': 'Android',
          'userAgent': 'Android ${androidInfo.version.release}; ${androidInfo.manufacturer} ${androidInfo.model}',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceInfo = {
          'deviceName': iosInfo.name,
          'model': iosInfo.model,
          'manufacturer': 'Apple',
          'osVersion': 'iOS ${iosInfo.systemVersion}',
          'platform': 'iOS',
          'userAgent': 'iOS ${iosInfo.systemVersion}; ${iosInfo.model}',
        };
      } else {
        deviceInfo = {
          'deviceName': 'Unknown Device',
          'model': 'Unknown',
          'manufacturer': 'Unknown',
          'osVersion': 'Unknown',
          'platform': Platform.operatingSystem,
          'userAgent': 'Unknown',
        };
      }
    } catch (e) {
      print('Error getting device info: $e');
      deviceInfo = {
        'deviceName': 'Unknown Device',
        'model': 'Unknown',
        'manufacturer': 'Unknown',
        'osVersion': 'Unknown',
        'platform': 'Unknown',
        'userAgent': 'Unknown',
      };
    }

    return deviceInfo;
  }

  // Retrieve device's public IP address using multiple fallback services
  Future<String> _getIPAddress() async {
    try {
      // Try multiple IP detection services for reliability
      final responses = await Future.wait([
        http.get(Uri.parse('https://api.ipify.org')),
        http.get(Uri.parse('https://api64.ipify.org')),
        http.get(Uri.parse('https://icanhazip.com')),
      ], eagerError: true);

      for (final response in responses) {
        if (response.statusCode == 200) {
          return response.body.trim();
        }
      }
    } catch (e) {
      print('Error getting IP address: $e');
    }

    return 'Unknown';
  }

  // Estimate geographic location based on IP address using IP geolocation API
  Future<String> _getLocationFromIP(String ipAddress) async {
    if (ipAddress == 'Unknown' || ipAddress == '127.0.0.1') {
      return 'Local Network';
    }

    try {
      final response = await http.get(
        Uri.parse('http://ip-api.com/json/$ipAddress?fields=country,city,regionName'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final country = data['country'] ?? 'Unknown Country';
        final city = data['city'] ?? 'Unknown City';
        final region = data['regionName'] ?? 'Unknown Region';

        return '$city, $region, $country';
      }
    } catch (e) {
      print('Error getting location from IP: $e');
    }

    return 'Unknown Location';
  }

  // Get current app version and build number from package info
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      print('Error getting app version: $e');
      return 'Unknown';
    }
  }

  // Update the last active timestamp for an existing session
  Future<void> updateSessionActivity(String sessionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .doc(sessionId)
          .update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating session activity: $e');
    }
  }

  // Mark a session as ended and record the end timestamp
  Future<void> endSession(String sessionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .doc(sessionId)
          .update({
        'isActive': false,
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  // Generate a unique session ID based on user, device, and network characteristics
  Future<String> generateSessionId() async {
    final user = _auth.currentUser;
    final deviceInfo = await _getDeviceInfo();
    final ipAddress = await _getIPAddress();

    // Create a unique session ID based on user, device, and IP combination
    final uniqueString = '${user?.uid}_${deviceInfo['model']}_$ipAddress';
    return _hashString(uniqueString);
  }

  // Simple hash function for generating consistent session IDs (demo purposes)
  String _hashString(String input) {
    // Simple hash function for demo purposes
    // In production, use a proper hash like SHA-256
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = (hash << 5) - hash + input.codeUnitAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.abs().toString();
  }
}
