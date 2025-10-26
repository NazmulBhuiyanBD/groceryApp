import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FavouriteProvider with ChangeNotifier{
  List<String>_favouriteIds=[];
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<String>get favourites=>_favouriteIds;
  FavouriteProvider(){
    loadFavorite();
  }

  void toggleFavourite(Map<String,dynamic>product)async{
    final productId=product['id'];
    if(_favouriteIds.contains(productId))
    {
      _favouriteIds.remove(productId);
      await _removeFavorite(productId);
    }
    else{
      _favouriteIds.add(productId);
    }
    notifyListeners();
  }
  bool isExit(Map<String,dynamic>product){
    final productId=product['id'];
    if(productId==null || productId is!String){
      return false;
    }
    return _favouriteIds.contains(productId);
  }
  Future<void>_addFavorite(String productId)async{
    try{
      await _firestore.collection("userFavourite").doc(productId).set({
        'isFavourite':true,
        "productId":productId,

      });
    }
    catch(e)
    {
      print(e.toString());
    }
  }
  Future<void>_removeFavorite(String productId)async{
    try{
      await _firestore.collection("userFavourite").doc(productId).delete();
    }
    catch(e)
    {
      print(e.toString());
    }
  }
  Future<void>loadFavorite()async{
    try{
      QuerySnapshot snapshot=await _firestore.collection("userFavourite").get();
      _favouriteIds=snapshot.docs.map((doc)=>doc.id).toList();
    }
    catch(e)
    {
      print(e.toString());
    }
    notifyListeners();
  }
  static FavouriteProvider of (BuildContext context,{bool listen=true})
  {
    return Provider.of<FavouriteProvider>(context,listen:listen);
  }
}