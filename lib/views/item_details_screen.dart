import 'package:flutter/material.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/widget/Cart_Icon.dart';
import 'package:grocery_app/widget/unit_conversion.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatelessWidget {
  const ItemDetailsScreen({super.key, required this.grocery});
  final Map<String, dynamic> grocery;

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider=Provider.of<CartProvider>(context);
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        elevation: 0,
        centerTitle: true,
        title: Text("Product Details", style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(onPressed: (){}, icon: CartIcon(),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              grocery['image'],
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              grocery['name'],
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.stars, color: Colors.amber),
                SizedBox(width: 5),
                Text(
                  grocery['rating'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "${grocery['price']}/${getUnit(grocery['category'])}",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            Text(
              grocery['category'].toString(),
              style: TextStyle(
                fontSize: 16,
                color: primarycolor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  "Description",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    (grocery['description'] as List<dynamic>?)
                        ?.map(
                          (item) => Text(
                            item.toString(),
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                        )
                        .toList() ??
                    [Text("No description available")],
              ),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 130,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: primarycolor,
                      ),
                      child: Text(
                        "Buy",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: primarycolor,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          cartProvider.addCart(grocery);
                        },
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
