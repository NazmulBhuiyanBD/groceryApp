import 'package:flutter/material.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/provider/favourite_provider.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/widget/unit_conversion.dart';
import 'package:provider/provider.dart';

class GroceryItems extends StatelessWidget {
  const GroceryItems({super.key,required this.grocery});
  final Map<String,dynamic>grocery;

  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<FavouriteProvider>(context);
    CartProvider cartProvider=Provider.of<CartProvider>(context);
    return Container(
      width: 192,
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: [
          Colors.white,
          Color(0xffF7FFF7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter),
        boxShadow:[
           BoxShadow(
          color: Colors.grey.withValues(alpha: .5),
          spreadRadius: 0,
          blurRadius: 7,
          offset: Offset(0, 3),
        ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 173,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                grocery['image'],
              ))
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(grocery['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("\$",style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),),
              Text("${grocery['price']}/${getUnit(grocery['category'])}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: -1
              ),)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                   color: primarycolor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      topRight:Radius.circular(30),
                      
                    )
                  ),
                  child: GestureDetector(
                    onTap: (){
                      provider.toggleFavourite(grocery);
                    },
                    child: Icon(
                      provider.isExit(grocery)?Icons.favorite:Icons.favorite_border,
                      color:provider.isExit(grocery)?Colors.red:  Colors.white,size: 27,),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                   color: primarycolor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(25),
                      topLeft:Radius.circular(30),
                      
                    )
                  ),
                  child: GestureDetector(
                    onTap: (){
                      cartProvider.addCart(grocery);
                    },
                    child: Icon(Icons.shopping_cart,color: Colors.white,size: 27,),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}