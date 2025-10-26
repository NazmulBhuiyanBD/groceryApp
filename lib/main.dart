import 'package:flutter/material.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/provider/favourite_provider.dart';
import 'package:grocery_app/views/grocery_main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => FavouriteProvider(),),
      ChangeNotifierProvider(create: (context) => CartProvider(),),
    ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: const GroceryMainPage(),
      ),
    );
  }
}

