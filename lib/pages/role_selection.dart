import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../child/child_dashboard.dart';
import '../parent/dashboard_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // Check if the user already has a role assigned
  Future<void> _checkUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
        final snapshot = await userRef.child('role').get();

        if (snapshot.exists) {
          final role = snapshot.value as String;
          _navigateBasedOnRole(role);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking role: $e')),
      );
    }
  }

  // Navigate based on the role
  void _navigateBasedOnRole(String role) {
    if (role == 'parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()), // Parent dashboard
      );
    } else if (role == 'child') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChildDashboard()), // Child dashboard
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid role. Please try again.')),
      );
    }
  }

  // Store role in Firebase Realtime Database
  Future<void> _storeRoleInDatabase(String role) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      await userRef.set({
        'role': role,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffaed7f5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/coloured_logo.png',
                height: 225,
                width: 225,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0), 
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(12), 
                boxShadow: [
                  BoxShadow(blurStyle: BlurStyle.normal,
                    color: const Color.fromARGB(255, 154, 169, 181).withOpacity(0.5), 
                    spreadRadius: 10, 
                    blurRadius: 10, 
                    offset: const Offset(3, 3), 
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Select your role:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 92, 151, 193),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Parent button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _storeRoleInDatabase('parent'); 
                      _navigateBasedOnRole('parent');
                    },
                    icon: const Icon(Icons.account_circle, size: 30, color: Color.fromARGB(255, 92, 151, 193),), 
                    label: const Text(
                      'Parent',
                    style: TextStyle(
                      color: Color.fromARGB(255, 92, 151, 193),
                      fontSize: 20,),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Child button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _storeRoleInDatabase('child'); // Store role as 'child'
                      _navigateBasedOnRole('child');
                    },
                    icon: const Icon(Icons.child_care, size: 30, color:Color.fromARGB(255, 92, 151, 193)), // Child icon
                    label: const Text(
                      'Child',
                    style: TextStyle(
                      color: Color.fromARGB(255, 92, 151, 193),
                      fontSize: 20,),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
