import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
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
  bool isLoading=true;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void>fetchData()async
  {
    await fetchCategory();
    if(groceryCategory.isNotEmpty)
    {
      category=groceryCategory[0]["name"];
      await filterProductCategory(category);
    }
    setState(() {
      isLoading=false;
    });
  }
  Future<void>fetchCategory() async {
    try{
      QuerySnapshot<Map<String,dynamic>>snapshot=await FirebaseFirestore.instance.collection("Category").get();
      setState(() {
        groceryCategory=snapshot.docs.map((docs)=>docs.data()).toList();
      });
    }catch(e)
    {
      print(e.toString());
    }
  }
  Future<void>filterProductCategory(String selectedCategory) async{
setState(() {
  isLoading=true;
  
});
    try{
      QuerySnapshot<Map<String,dynamic>>snapshot=await FirebaseFirestore.instance.collection("myAppCollection").where('category',isEqualTo: selectedCategory).get();
      setState(() {
        category=selectedCategory;
        groceryItem=snapshot.docs.map((docs)=>docs.data()).toList();
      });
    }catch(e)
    {
      print(e.toString());
    }
    finally{
      setState(() {
        isLoading=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                      children: [
                        TextSpan(text: "Hello"),
                        TextSpan(
                          text: "Smith\n",
                          style: TextStyle(color: primarycolor),
                        ),
                        TextSpan(
                          text: "what do you need",
                          style: TextStyle(fontSize: 17, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.shopping_cart_outlined, size: 27),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Text(
                "Quality you can taste ,freshness you can trust",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
              child: MySearchBar(onsearch: (p) {}),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                  child: Row(
                    children: [
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
                  padding: EdgeInsets.only(left: 15, top: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        groceryCategory.length,
                        (index) => Padding(
                          padding: EdgeInsetsGeometry.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              filterProductCategory(groceryCategory[index]['name']);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5),
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
                                  SizedBox(height: 5),
                                  Text(
                                    groceryCategory[index]['name'],
                                    style: TextStyle(
                                      fontWeight:
                                          category ==
                                              groceryCategory[index]['name']
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                  child: Row(
                    children: [
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.keyboard_arrow_right, color: Colors.black),
                    ],
                  ),
                ),

              ],
            ),
            groceryItem.isEmpty? Center(
              child: Padding(padding: EdgeInsets.symmetric(vertical: 30),
              child: Text("No Product available",style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500
              ),),
              ),
            ): SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              
              child: Row(
                children:List.generate(groceryItem.length, (index)
                {
                  return Padding(padding: EdgeInsets.only(left: 15,top: 15,bottom: 15),
                  child: GestureDetector(
                    onTap: (){},
                    child: GroceryItems(grocery: groceryItem[index]),
                  ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
