// import 'package:flutter/material.dart';
// import 'package:usage_stats/usage_stats.dart';

// class ScreenTimeService {
//   Future<List<UsageInfo>> getScreenTimeData(BuildContext context) async {
//     try {
//       DateTime endDate = DateTime.now();
//       DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

//       // Grant usage permission
//       UsageStats.grantUsagePermission();

//       // Check if permission is granted
//       bool isPermissionGranted = await UsageStats.checkUsagePermission() ?? false;

//       if (isPermissionGranted) {
//         // Query usage stats
//         List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
//         return usageStats;
//       } else {
//         // Show alert dialog if permission is not granted
//         _showPermissionDeniedAlert(context);
//         return [];
//       }
//     } catch (e) {
//       print("Error fetching screen time data: $e");
//       return [];
//     }
//   }

//   // Function to show an alert if permission is not granted
//   void _showPermissionDeniedAlert(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Permission Denied"),
//           content: Text("Screen time permission is required to fetch app usage data."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
