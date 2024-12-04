import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScreenTime {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<int> fetchScreenTime(String userId) async {
    try {
      // Check if the user is authenticated
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }
      // Fetch connected device ID
      final deviceLinkedSnapshot = await _database.child('users').child(userId).child('deviceLinked').get();
      final String? deviceId = deviceLinkedSnapshot.value as String?;

      if (deviceId == null) {
        throw Exception("No connected device found.");
      }
      // Fetch screen time for the connected device
      final screentimeSnapshot = await _database.child('devices').child(deviceId).child('screentime').child('today').get();

      if (!screentimeSnapshot.exists) {
        throw Exception("No screen time data found.");
      }

      // Return today's screen time in minutes
      return screentimeSnapshot.value as int;
    } catch (e) {
      print("Error fetching screen time: $e");
      return 0; // Default value on error
    }
  }
}