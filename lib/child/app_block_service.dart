import 'package:firebase_database/firebase_database.dart';

class ChildAppBlockService {
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
}
