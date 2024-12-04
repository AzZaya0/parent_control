import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DeviceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Connect a device and update Firebase
  Future<void> connectDevice(String deviceName, String osType) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in!");

      // Check if a device is already linked to the user
      final userSnapshot = await _database.ref('users/$userId/deviceLinked').get();
      if (userSnapshot.exists && userSnapshot.value != null) {
        throw Exception("A device is already linked to this user.");
      }

      // Generate a unique device ID
      final String deviceId = DateTime.now().millisecondsSinceEpoch.toString();

      // Prepare the device data
      final deviceData = {
        'metadata': {
          'deviceName': deviceName,
          'connected': true,
          'osType': osType,
        },
        'userId': userId, // Corrected field
        'appblock': {
          'blockedApps': [], // Initialize as empty
        },
        'monitor': {
          'battery': 100, // Default battery level
          'lastActive': DateTime.now().toIso8601String(),
        },
        'screentime': {
          'today': 0, // Default screen time for today
          'week': 0,  // Default screen time for the week
        },
      };

      // Save device data to the Realtime Database
      await _database.ref('devices/$deviceId').set(deviceData);

      // Update the user's 'deviceLinked' field to link the device
      await _database.ref('users/$userId').update({'deviceLinked': deviceId});
    } catch (e) {
      throw Exception("Error connecting device: $e");
    }
  }

  // Check if the device is already connected for the user
  Future<bool> isDeviceConnected() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in!");

      // Check if the user has a linked device
      final deviceSnapshot = await _database.ref('users/$userId/deviceLinked').get();
      return deviceSnapshot.exists && (deviceSnapshot.value != null);
    } catch (e) {
      print("Error checking device connection: $e");
      return false; // Default to not connected in case of an error
    }
  }
}
