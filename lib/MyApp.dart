import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';

import 'pages/connect_device_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'parent/dashboard_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Check if the user is a first-time user (stored in SharedPreferences)
  Future<bool> _checkFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;
    print('isFirstLogin read as: $isFirstLogin'); // Debugging print statement
    return isFirstLogin;
  }

  // Set the flag 'isFirstLogin' to false after the device is connected
  Future<void> _setFirstLoginFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLogin', false);
  }

  // Check if a device is connected for the current user
  Future<bool> _isDeviceConnected() async {
    // Ensure FirebaseAuth is initialized and a user is signed in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final DatabaseReference userDevicesRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('device');

    final DataSnapshot snapshot = await userDevicesRef.get();
    return snapshot.exists && snapshot.children.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/',
      routes: {
        // Login route
        '/login': (context) => const LoginPage(),

        // Sign up route
        '/signup': (context) => const SignUpPage(),

        // ConnectDevicePage
        '/connect_device_page': (context) => ConnectDevicePage(
              onConnected: () async {
                // Mark as not a first-time user once the device is connected
                await _setFirstLoginFalse();
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),

        // DashboardPage route
        '/dashboard': (context) => const DashboardPage(),

        // Main page logic for the first login or not
        '/': (context) => FutureBuilder<bool>(
              future: _checkFirstLogin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred'));
                } else {
                  final isFirstLogin = snapshot.data ?? true;

                  return FutureBuilder<bool>(
                    future: _isDeviceConnected(),
                    builder: (context, deviceSnapshot) {
                      if (deviceSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (deviceSnapshot.hasError) {
                        return const Center(child: Text('An error occurred'));
                      } else {
                        final isDeviceConnected = deviceSnapshot.data ?? false;

                        // If it's the first login and no device is connected, navigate to ConnectDevicePage
                        if (isFirstLogin && !isDeviceConnected) {
                          return ConnectDevicePage(
                            onConnected: () async {
                              await _setFirstLoginFalse(); // Set isFirstLogin flag to false
                              Navigator.pushReplacementNamed(
                                  context, '/dashboard');
                            },
                          );
                        } else {
                          // If the user has connected a device or is not a first-time user, navigate to DashboardPage
                          return const DashboardPage();
                        }
                      }
                    },
                  );
                }
              },
            )
      },
    );
  }
}
