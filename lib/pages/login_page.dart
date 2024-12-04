import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parent_control/child/child_dashboard.dart';
import 'package:parent_control/pages/role_selection.dart';
import 'package:parent_control/pages/signup_page.dart';
import 'package:parent_control/parent/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _login() async {
    try {
      // User Login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final User? user = _auth.currentUser;

      if (user != null) {
        final String uid = user.uid;

        // Check user role (fetch from Firebase or SharedPreferences)
        String role = await _getUserRole(uid);

        // Navigate to the role selection page if no role is set yet
        if (role.isEmpty) {
          _navigateTo(const RoleSelectionPage());
        } else {
          // Navigate to dashboard based on the role
          _navigateTo(
              role == "parent" ? const DashboardPage() : ChildDashboard());
        }
      }
    } catch (e) {
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }
  }

  Future<String> _getUserRole(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if role exists in Shared Preferences
    String? role = prefs.getString('userRole');

    if (role == null || role.isEmpty) {
      // Fetch role from Firebase if not available locally
      try {
        final snapshot =
            await _database.child("users").child(userId).child("role").get();
        if (snapshot.exists) {
          role = snapshot.value as String;

          // Save role in Shared Preferences
          await prefs.setString('userRole', role);
        }
      } catch (e) {
        print("Error checking user role: $e");
      }
    }

    return role ?? ''; // Return role or empty if not found
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/digital_login_logo.png',
                          height: 130,
                        ),
                        const SizedBox(height: 80),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                labelText: "Email",
                                prefixIcon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 15),
                              _buildTextField(
                                controller: _passwordController,
                                labelText: "Password",
                                prefixIcon: Icons.lock,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (value.length < 6) {
                                    return 'Password should be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _login();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextButton(
                                onPressed: () {
                                  _navigateTo(const SignUpPage());
                                },
                                child: const Text(
                                  "Don't have an account? Sign Up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}
