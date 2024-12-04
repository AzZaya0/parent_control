import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request activity recognition permission
  Future<bool> requestActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      return true;  // Permission granted
    } else {
      return false;  // Permission denied
    }
  }

  // You can add other permissions in a similar way if needed
  Future<bool> requestUsageStatsPermission() async {
    var status = await Permission.accessMediaLocation.request(); // Modify according to your needs
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
