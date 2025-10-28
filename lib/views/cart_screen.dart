import 'package:flutter/material.dart';
import 'package:grocery_app/provider/Model/cart_model.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/widget/cart_items.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider=Provider.of<CartProvider>(context);
    List<CartModel>carts=cartProvider.carts.reversed.toList();
    Size size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
forceMaterialTransparency: true,
backgroundColor: secondarycolor,
elevation:0 ,
centerTitle: true,
title: const Text("My Cart",
style: TextStyle(
color: Colors.black,
fontWeight: FontWeight.bold
),),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(height: size.height *0.5,
          child: SingleChildScrollView(
scrollDirection: Axis.vertical,
physics: BouncingScrollPhysics(
),child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: List.generate(carts.length, (index) => SizedBox(
    height: 100,
    width: size.width,
    child: CartItems(cart: carts[index],),
  ),),
),
          ),),
          ),
        )
      ),
      bottomSheet: carts.isEmpty?Container(color: secondarycolor,
      child: Center(
        child: Text("Don't have any items on the cart"),
      ),):Container(
        color: secondarycolor,
        height: size.height*0.345,
        child: Padding(padding: EdgeInsets.symmetric(
          horizontal: 15
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total",style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ), 
                ),
                Text("\$${cartProvider.totalCart().toStringAsFixed(2)}",style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:primarycolor
                ),),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                Checkbox(value: true, onChanged:null,activeColor: primarycolor,),
                Text("Delivery Charge",style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),),
                Spacer(),
                Text("\$4.99",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primarycolor
                ),)
              ],
            ),
                        Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                Checkbox(value: true, onChanged:null,activeColor: primarycolor,),
                Text("Eco-friendly Packaging : Paper-Bag",style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),),
                Spacer(),
                Text("\$${(carts.length*0.1).toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primarycolor
                ),)
              ],
            ),
            SizedBox(width: size.width*0.75,
            child: Text("Help us to reduce the use of plastic by Buy paper Bags",
            style: TextStyle(
              fontSize: 12
            ),),),
            SizedBox(height: 15,),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Price",style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ), 
                ),
                Text("\$${(cartProvider.totalCart()+4.99+0.1*carts.length).toStringAsFixed(2)}",style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:primarycolor
                ),),
              ],
            ),
            SizedBox(height: 15,),
            Container(
              height: 45,
              alignment: Alignment.center,decoration: BoxDecoration(
                color: primarycolor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.7),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 2),

                ),

                ],

              ),
              child: Text("Process to Checkout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),),
            ),
          ],
        ),
        ),
      )
    );
  }
}