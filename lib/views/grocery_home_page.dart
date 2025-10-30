import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/views/item_details_screen.dart';
import 'package:grocery_app/views/see_all_product.dart';
import 'package:grocery_app/widget/Cart_Icon.dart';
import 'package:grocery_app/widget/grocery_items.dart';
import 'package:grocery_app/widget/my_search_bar.dart';

class GroceryHomePage extends StatefulWidget {
  const GroceryHomePage({super.key});

  @override
  State<GroceryHomePage> createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<GroceryHomePage> {
  String category = '';
  List<Map<String, dynamic>> groceryItem = [];
  List<Map<String, dynamic>> groceryCategory = [];
  List<Map<String, dynamic>> recentItems = []; // 🔹 Recently sold items
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchCategory();
    if (groceryCategory.isNotEmpty) {
      category = groceryCategory[0]["name"];
      await filterProductCategory(category);
    }
    await fetchRecentSoldProducts(); 
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCategory() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection("Category").get();
      setState(() {
        groceryCategory = snapshot.docs.map((docs) => docs.data()).toList();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> filterProductCategory(String selectedCategory) async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("myAppCollection")
          .where('category', isEqualTo: selectedCategory)
          .get();
      setState(() {
        category = selectedCategory;
        groceryItem = snapshot.docs.map((docs) => docs.data()).toList();
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchRecentSoldProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection("myAppCollection").get();

      List<Map<String, dynamic>> allItems =
          snapshot.docs.map((doc) => doc.data()).toList();

      if (allItems.isNotEmpty) {
        allItems.shuffle(Random()); // Randomize the order
        recentItems = allItems.take(6).toList(); 
      }
    } catch (e) {
      print("Error fetching recent sold products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                        children: [
                          TextSpan(
                            text: "GroceryApp\n",
                            style: TextStyle(color: primarycolor),
                          ),
                          const TextSpan(
                            text: "Buy Your Desire Product",
                            style:
                                TextStyle(fontSize: 17, color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const CartIcon(),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SeeAllProduct(),
                      ),
                    );
                  },
                  child: AbsorbPointer(
                    child: MySearchBar(
                      onsearch: (p) {},
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: const [
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "See All",
                      style: TextStyle(fontSize: 16, color: Colors.black38),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: Colors.black38),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 15, top: 5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      groceryCategory.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            filterProductCategory(
                                groceryCategory[index]['name']);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width:
                                    category == groceryCategory[index]['name']
                                        ? 2
                                        : 1,
                                color:
                                    category == groceryCategory[index]['name']
                                        ? primarycolor
                                        : Colors.black45,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primarycolor,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        groceryCategory[index]['image'],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  groceryCategory[index]['name'],
                                  style: TextStyle(
                                    fontWeight:
                                        category == groceryCategory[index]
                                                ['name']
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Text(
                      "Find By Category",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeeAllProduct(),
                          ),
                        );
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_right,
                        color: Colors.black),
                  ],
                ),
              ),

              groceryItem.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          "No Product available",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          groceryItem.length,
                          (index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, top: 15, bottom: 15),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailsScreen(
                                        grocery: groceryItem[index],
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    GroceryItems(grocery: groceryItem[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    const Text(
                      "Best Selling",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SeeAllProduct(),
                          ),
                        );
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_right,
                        color: Colors.black),
                  ],
                ),
              ),

              recentItems.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No recently sold products found",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 15, top: 15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            recentItems.length,
                            (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 15, bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemDetailsScreen(
                                          grocery: recentItems[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      GroceryItems(grocery: recentItems[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
