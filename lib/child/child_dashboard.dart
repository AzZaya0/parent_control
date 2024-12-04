import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parent_control/child/app_block_service.dart';
// import 'package:usage_stats/usage_stats.dart';


class ChildDashboard extends StatefulWidget {
  @override
  _ChildDashboardState createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  final databaseReference = FirebaseDatabase.instance.ref();
  // final screenTimeService = ScreenTimeService(); //
  final appBlockService = ChildAppBlockService();
  Map<String, dynamic> appUsage = {};
  Map<String, dynamic> appLimits = {};
  Map<String, bool> blockedApps = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppData();
    // _fetchScreenTimeData();
  }

  // Fetch app usage, limits, and blocked apps data from Firebase
  void _fetchAppData() async {
    final childId = 'childID123'; // Example child ID

    try {
      // Fetching app usage data from Firebase
      DataSnapshot usageSnapshot =
          await databaseReference.child('devices/$childId/appUsage').get();
      DataSnapshot limitsSnapshot =
          await databaseReference.child('devices/$childId/appLimits').get();
      DataSnapshot blockedAppsSnapshot =
          await databaseReference.child('devices/$childId/blockedApps').get();

      setState(() {
        appUsage = Map<String, dynamic>.from(usageSnapshot.value as Map? ?? {});
        appLimits =
            Map<String, dynamic>.from(limitsSnapshot.value as Map? ?? {});
        blockedApps =
            Map<String, bool>.from(blockedAppsSnapshot.value as Map? ?? {});
      });
    } catch (e) {
      print("Error fetching app data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch real-time screen time data using ScreenTimeService
  // void _fetchScreenTimeData() async {
  //   try {
  //     final screenTimeData = await screenTimeService.getScreenTimeData(context);

  //     setState(() {
  //       for (var usage in screenTimeData) {
  //         appUsage[usage.packageName ?? "Unknown"] = ((usage.totalTimeInForeground ?? 0) as num).toDouble() / 1000 / 60;
  //       }
  //     });
  //   } catch (e) {
  //     print("Error fetching real-time screen time data: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Child Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while data is being fetched
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("App Usage",
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  _buildAppUsageTile("YouTube"),
                  _buildAppUsageTile("Instagram"),
                  SizedBox(height: 32),
                  Text("App Limits",
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  _buildAppLimitTile("YouTube"),
                  _buildAppLimitTile("Instagram"),
                  SizedBox(height: 32),
                  Text("Blocked Apps",
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  _buildBlockedAppTile("YouTube"),
                  _buildBlockedAppTile("Instagram"),
                ],
              ),
      ),
    );
  }

  // Widget to display app usage data
  Widget _buildAppUsageTile(String appName) {
    return Card(
      color: Colors.blue[50],
      child: ListTile(
        title: Text(appName),
        subtitle: Text("Usage: ${appUsage[appName] ?? 'N/A'} minutes"),
        trailing: Icon(Icons.access_time),
      ),
    );
  }

  // Widget to display app limit data
  Widget _buildAppLimitTile(String appName) {
    return Card(
      color: Colors.blue[50],
      child: ListTile(
        title: Text(appName),
        subtitle: Text("Limit: ${appLimits[appName] ?? 'N/A'} minutes"),
        trailing: Icon(Icons.timer),
      ),
    );
  }

  // Widget to display blocked app status
  Widget _buildBlockedAppTile(String appName) {
    return Card(
      color: Colors.blue[50],
      child: ListTile(
        title: Text(appName),
        subtitle:
            Text(blockedApps[appName] == true ? "Blocked" : "Not Blocked"),
        trailing:
            Icon(blockedApps[appName] == true ? Icons.block : Icons.check),
      ),
    );
  }
}
