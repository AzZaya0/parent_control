import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parent_control/child/child_dashboard.dart';
import 'package:parent_control/parent/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/device_services.dart';

class ConnectDevicePage extends StatefulWidget {
  final VoidCallback? onConnected; // Callback when device is connected

  const ConnectDevicePage({Key? key, this.onConnected}) : super(key: key);

  @override
  _ConnectDevicePageState createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  final DeviceService _deviceService = DeviceService();
  final TextEditingController _deviceNameController = TextEditingController();
  bool _isConnecting = false;
  String _osType = 'Android';

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication(); // Check if user is authenticated
  }

  // Method to handle user authentication check
  Future<void> _checkUserAuthentication() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        // If the user is not authenticated, navigate to login page
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  // Method to handle device connection
  Future<void> _connectDevice() async {
    setState(() {
      _isConnecting = true;
    });

    if (_deviceNameController.text.isEmpty) {
      _showSnackBar('Please provide a device name!');
      _setConnectingState(false);
      return;
    }

    try {
      // Connect the device using the DeviceService
      await _deviceService.connectDevice(_deviceNameController.text, _osType);

      // Mark the user as no longer a first-time user
      await _markUserAsNotFirstLogin();

      // Invoke the callback to signal that the device has been connected
      if (widget.onConnected != null) {
        widget.onConnected!();
      }

      // Get the user role from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final String? userRole =
          prefs.getString('userRole'); // 'parent' or 'child'

      // Navigate to the appropriate dashboard based on the role
      if (userRole == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else if (userRole == 'child') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChildDashboard()),
        );
      } else {
        // Default case if role isn't set
        _showSnackBar('Role not set. Please choose your role first.');
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      _setConnectingState(false);
    }
  }

  // Helper to show SnackBar messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper to set the connecting state
  void _setConnectingState(bool isConnecting) {
    setState(() {
      _isConnecting = isConnecting;
    });
  }

  // Helper to mark the user as not first login using SharedPreferences
  Future<void> _markUserAsNotFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLogin', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(), // Custom method to build the header
            const SizedBox(height: 30),
            _buildDeviceNameField(), // Custom method for the device name input
            const SizedBox(height: 20),
            _buildOSDropdown(), // Custom method for the OS selection dropdown
            const SizedBox(height: 20),
            _buildConnectButton(), // Custom method for the Connect button
          ],
        ),
      ),
    );
  }

  // Header UI with logo and instructions
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/dg_logo.png', height: 100, width: 100),
          const SizedBox(height: 20),
          const Text('Your Digital Guardian!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Get started Now',
              style: TextStyle(fontSize: 14, color: Colors.blue)),
        ],
      ),
    );
  }

  // Device Name input field
  Widget _buildDeviceNameField() {
    return TextField(
      controller: _deviceNameController,
      decoration: InputDecoration(
        labelText: 'Device Name',
        border: OutlineInputBorder(),
      ),
    );
  }

  // OS Type dropdown
  Widget _buildOSDropdown() {
    return DropdownButton<String>(
      value: _osType,
      onChanged: (String? newValue) {
        setState(() {
          _osType = newValue!;
        });
      },
      items: <String>['Android', 'iOS']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // Connect button or progress indicator
  Widget _buildConnectButton() {
    return _isConnecting
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: _connectDevice,
            child: const Text('Connect Device'),
          );
  }
}
