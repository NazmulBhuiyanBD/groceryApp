import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grocery_app/views/admin/admin_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/provider/favourite_provider.dart';
import 'package:grocery_app/views/grocery_main_page.dart';
import 'package:grocery_app/views/login_screen.dart';
import 'package:grocery_app/services/auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load .env from assets
  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Grocery App",
        theme: ThemeData(primarySwatch: Colors.green),
        home: StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            // 🕒 Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ✅ If user logged in
            if (snapshot.hasData && snapshot.data != null) {
              final user = snapshot.data!;

              // 🔹 Check user role from Firestore
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // 🚫 If no user data found, go back to login
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const LoginScreen();
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  // 🟩 Check if admin
                  if (userData != null &&
                      userData.containsKey('isAdmin') &&
                      userData['isAdmin'] == true) {
                    return const AdminDashboardScreen();
                  }

                  // 🟨 Otherwise, normal customer
                  return const GroceryMainPage();
                },
              );
            }

            // 🚪 Not logged in
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
