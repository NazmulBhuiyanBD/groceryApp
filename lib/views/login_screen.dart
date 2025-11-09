import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:grocery_app/services/auth.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/views/admin/admin_dashboard_screen.dart';
import 'package:grocery_app/views/admin/admin_login_screen.dart';
import 'package:grocery_app/views/grocery_main_page.dart';
import 'package:grocery_app/views/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleEmailLogin({bool isAdminLogin = false}) async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final user = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid credentials")),
        );
        setState(() => _loading = false);
        return;
      }

      // 🔹 Get Firestore user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found in Firestore")),
        );
        setState(() => _loading = false);
        return;
      }

      final data = userDoc.data();
      final isAdmin = data?['isAdmin'] ?? false;

      // 🔒 If admin login button was pressed but user isn’t admin
      if (isAdminLogin && !isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ You are not authorized as Admin")),
        );
        await _authService.signOut();
        setState(() => _loading = false);
        return;
      }

      // ✅ Redirect based on role
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GroceryMainPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);
    final user = await _authService.signInWithGoogle();
    setState(() => _loading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GroceryMainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-In failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/logoIcon.png", height: 200),
              const SizedBox(height: 10),
              const Text(
                "Welcome to Grocery App",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        // 🟩 Login as Customer
                        ElevatedButton(
                          onPressed: () => _handleEmailLogin(isAdminLogin: false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primarycolor,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: const Text(
                            "Login Now",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 🔴 Login as Admin


                      ],
                    ),
              const SizedBox(height: 10),

              // Register Button




              // Google Login
              ElevatedButton.icon(
                icon: Image.asset('assets/google.png', height: 25),
                label: const Text("Continue with Google"),
                onPressed: _handleGoogleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: Colors.black26),
                  ),
                ),
              ),              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
                  const Divider(height: 30, thickness: 1),          
              TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
  },
  
  child: const Text(
    "Login as Admin",
    style: TextStyle(fontSize: 16, color: Colors.deepPurple),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
