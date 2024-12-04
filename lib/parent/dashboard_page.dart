import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parent_control/parent/app_block_service.dart';
import 'package:parent_control/parent/screen_time.dart';

import '../pages/logout_page.dart';
import '../pages/connect_device_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final ParentAppBlockService _appBlockService = ParentAppBlockService();
  final ScreenTime _screentimeService = ScreenTime();

  String? _deviceName;
  int _screenTime = 0;
  List<String> _blockedApps = [];
  bool _isLoading = true;
  String? _childDeviceId;

  @override
  void initState() {
    super.initState();
    _validateAndFetchData();
  }

  Future<void> _validateAndFetchData() async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null) {
        _redirectToLogin();
        return;
      }

      // Validate and fetch childDeviceId
      final userRef = _database.child('users/$userId');
      final deviceSnapshot = await userRef.child('childDeviceId').get();

      if (!deviceSnapshot.exists || deviceSnapshot.value == null) {
        _redirectToDeviceLinking();
        return;
      }

      _childDeviceId = deviceSnapshot.value as String;
      await _fetchDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _redirectToDeviceLinking() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConnectDevicePage()),
    );
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogoutPage()),
    );
  }

  Future<void> _fetchDashboardData() async {
    if (_childDeviceId == null) return;

    final childDeviceRef = _database.child('devices/$_childDeviceId!');

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        childDeviceRef.child('metadata/deviceName').get(),
        _screentimeService.fetchScreenTime(_childDeviceId!),
        childDeviceRef.child('appblock/blockedApps').get(),
      ]);

      // Process the results
      final DataSnapshot metadataSnapshot = results[0] as DataSnapshot;
      final int screentime = results[1] as int;
      final DataSnapshot blockedAppsSnapshot = results[2] as DataSnapshot;

      setState(() {
        _deviceName = metadataSnapshot.value as String?;
        _screenTime = screentime;
        _blockedApps = blockedAppsSnapshot.value != null
            ? List<String>.from(blockedAppsSnapshot.value as List)
            : [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching dashboard data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _blockApp(String appName) async {
    try {
      if (_childDeviceId == null) throw Exception("No child device linked.");
      await _appBlockService.blockApp(_childDeviceId!, appName);
      _fetchDashboardData(); // Refresh the data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to block app: $e")),
      );
    }
  }

  Future<void> _unblockApp(String appName) async {
    try {
      if (_childDeviceId == null) throw Exception("No child device linked.");
      await _appBlockService.unblockApp(_childDeviceId!, appName);
      _fetchDashboardData(); // Refresh the data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to unblock app: $e")),
      );
    }
  }

  void _showAppSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<String> availableApps = ["App1", "App2", "App3"]; // Replace with actual app list

        return AlertDialog(
          title: const Text("Select an App to Block"),
          content: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: availableApps.length,
              itemBuilder: (context, index) {
                final appName = availableApps[index];
                return ListTile(
                  title: Text(appName),
                  trailing: IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    onPressed: () {
                      _blockApp(appName);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/dg_logo.png', height: 40),
            const SizedBox(width: 10),
            const Text(
              'Digital Guardian',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black45),
            onPressed: _redirectToLogin,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Child's Device: $_deviceName"),
            Text("Screen Time Today: $_screenTime minutes"),
            const SizedBox(height: 10),
            const Text("Blocked Apps:"),
            if (_blockedApps.isEmpty)
              const Text("No apps are blocked.")
            else
              ..._blockedApps.map((app) => ListTile(
                title: Text(app),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _unblockApp(app),
                ),
              )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAppSelectionDialog,
              child: const Text("Block New App"),
            ),
          ],
        ),
      ),
    );
  }
}
