import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/views/item_details_screen.dart';
import 'package:grocery_app/widget/grocery_items.dart';
import 'package:grocery_app/widget/my_search_bar.dart';

class SeeAllProduct extends StatefulWidget {
  const SeeAllProduct({super.key});

  @override
  State<SeeAllProduct> createState() => _SeeAllProductState();
}

class _SeeAllProductState extends State<SeeAllProduct> {
  List<Map<String, dynamic>> groceryItems = [];
  List<Map<String, dynamic>> filterItems = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchAllProduct();
  }

  Future<void> fetchAllProduct() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("myAppCollection")
          .get();
      setState(() {
        groceryItems = snapshot.docs.map((docs) => docs.data()).toList();
        filterItems = groceryItems;
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searhFilterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        filterItems = groceryItems;
      });
    } else {
      setState(() {
        filterItems = groceryItems.where((item) {
          return item['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "All Grocery Product",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart)),
          SizedBox(width: 15),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MySearchBar(onsearch: searhFilterItems),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 720,
                        width: double.maxFinite,
                        child: GridView.builder(
                          itemCount: filterItems.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.631,
                              ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                  context,MaterialPageRoute(builder:(context) => ItemDetailsScreen(
                                    grocery: groceryItems[index],),)
                                );
                              },
                              child: GroceryItems(grocery: filterItems[index]),
                            );
                            
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
