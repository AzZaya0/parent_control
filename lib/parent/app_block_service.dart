import 'package:firebase_database/firebase_database.dart';

class ParentAppBlockService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Fetch the list of blocked apps for a device
  Future<List<String>> fetchBlockedApps(String deviceId) async {
    try {
      final deviceRef = _database.child('devices').child(deviceId).child('appblock');
      final snapshot = await deviceRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return List<String>.from(data['blockedApps'] ?? []);
      } else {
        throw Exception("No app block data found for this device.");
      }
    } catch (e) {
      throw Exception("Error fetching blocked apps: $e");
    }
  }

  // Add an app to the block list for a device
  Future<void> blockApp(String deviceId, String appName) async {
    try {
      final deviceRef = _database.child('devices').child(deviceId).child('appblock');
      final blockedAppsSnapshot = await deviceRef.child('blockedApps').get();

      List<String> blockedApps = [];
      if (blockedAppsSnapshot.exists) {
        blockedApps = List<String>.from(blockedAppsSnapshot.value as List);
      }

      if (!blockedApps.contains(appName)) {
        blockedApps.add(appName);
        await deviceRef.update({'blockedApps': blockedApps});
        print("App '$appName' blocked successfully.");
      } else {
        print("App '$appName' is already blocked.");
      }
    } catch (e) {
      throw Exception("Error blocking app: $e");
    }
  }

  // Remove an app from the block list for a device
  Future<void> unblockApp(String deviceId, String appName) async {
    try {
      final deviceRef = _database.child('devices').child(deviceId).child('appblock');
      final blockedAppsSnapshot = await deviceRef.child('blockedApps').get();

      List<String> blockedApps = [];
      if (blockedAppsSnapshot.exists) {
        blockedApps = List<String>.from(blockedAppsSnapshot.value as List);
      }

      if (blockedApps.contains(appName)) {
        blockedApps.remove(appName);
        await deviceRef.update({'blockedApps': blockedApps});
        print("App '$appName' unblocked successfully.");
      } else {
        print("App '$appName' was not blocked.");
      }
    } catch (e) {
      throw Exception("Error unblocking app: $e");
    }
  }
}
