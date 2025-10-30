import 'package:flutter/material.dart';
import 'package:grocery_app/services/auth.dart';
import 'package:grocery_app/utils/constrain.dart';
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

 Future<void> _handleEmailLogin() async {
  if (!mounted) return; // guard before anything
  setState(() => _loading = true);
  try {
    final user = await _authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // Widget may have been disposed by now due to authStateChanges
    if (!mounted) return;

  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Login failed: $e")));
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
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
              Image.asset("assets/icons/logoIcon.png",height: 200,),
              SizedBox(height: 10,),
              const Text(
                "Welcome to Grocery App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
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
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)),),
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleEmailLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primarycolor,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text("Login",style: TextStyle(color: Colors.black),),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
              const Divider(height: 30, thickness: 1),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
