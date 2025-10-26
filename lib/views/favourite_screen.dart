import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/provider/favourite_provider.dart';
import 'package:grocery_app/widget/unit_conversion.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<FavouriteProvider>(context);
    final favoriteItems=provider.favourites;
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        centerTitle: true,
        title: Text("Favorite",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: favoriteItems.isEmpty?Center(
        child: Text("No Favorite Yet",style: TextStyle(
          fontSize: 18,
          fontWeight:FontWeight.bold,
        ),),
      ):ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
        String favorite=favoriteItems[index];
return FutureBuilder<DocumentSnapshot>(future: FirebaseFirestore.instance.collection("myAppCollection").doc(favorite).get(),
builder: (context, snapshot) {
  if(!snapshot.hasData ||!snapshot.data!.exists)
  {
    return Center(
      child: Text("Error Loading Favorites"),
    );
  }
  var favoriteItems=snapshot.data!.data()as Map<String,dynamic>?;
  if(favoriteItems==null)
  {
return Center(
  child: Text("No data available for this favorite."),
);

  }
  return Stack(
    children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 15,vertical: 8),
      child: Container(
        padding: EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0,2)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(fit: BoxFit.cover,image: NetworkImage(favoriteItems['image']))
              ),
            ),
            SizedBox(
              width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(favoriteItems['name'],style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),),
                  SizedBox(height: 5,),
                  Text("\$${favoriteItems['price']}/${getUnit(favoriteItems['category'])}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),)
                ],
              )
          ],
        ),
      ),
      ),
      Positioned(
        top: 50,
        right: 35,
        child: GestureDetector(
          onTap: () {
            setState(() {
              provider.toggleFavourite(favoriteItems);
            });
          },
          child: Icon(Icons.delete,
          color: Colors.red,
          size: 25,),
        ),)
    ],
  );
},

);
      },
      ),
    );
  }
}