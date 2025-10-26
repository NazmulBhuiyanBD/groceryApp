import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/views/favourite_screen.dart';
import 'package:grocery_app/views/grocery_home_page.dart';
import 'package:iconsax/iconsax.dart';

class GroceryMainPage extends StatefulWidget {
  const GroceryMainPage({super.key});

  @override
  State<GroceryMainPage> createState() => _GroceryMainPageState();
}

class _GroceryMainPageState extends State<GroceryMainPage> {

  int selectedIndex=0;
  final List pages=[
    GroceryHomePage(),
    FavouriteScreen(),
    const Scaffold(
      body: Center(
        child: Text("Cart"),
      ),
    ),
    const Scaffold(
      body: Center(
        child: Text("Profile"),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primarycolor,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedItemColor: Colors.black45,
        elevation: 0,
        backgroundColor: secondarycolor,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value){
          setState(() {
            selectedIndex=value;
          });
        },

        items: const [
        BottomNavigationBarItem(icon: Icon(Iconsax.home5),
        activeIcon: Icon(Iconsax.home5),
        label: "Home"),
        BottomNavigationBarItem(icon: Icon(Iconsax.heart),
        activeIcon: Icon(Iconsax.heart5),
        label: "Favourite"),
        BottomNavigationBarItem(icon: Icon(Iconsax.shopping_cart),
        activeIcon: Icon(Iconsax.shopping_cart5),
        label: "Cart"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: "Profile"),
      ],),
      body: pages[selectedIndex],

    );
  }
}