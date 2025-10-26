import 'package:flutter/foundation.dart';
import 'package:grocery_app/provider/Model/cart_model.dart';

class CartProvider with ChangeNotifier{
List<CartModel>_carts=[];
List<CartModel>get carts=>_carts;
set carts(List<CartModel>carts)
{
_carts=carts;
notifyListeners();
}
void addCart(Map<String,dynamic>grocery)
{
  if(productExits(grocery))
  
  {
    int index=_carts.indexWhere((element)=>element.grocery['id']==grocery['id']);
    _carts[index].quantity=_carts[index].quantity+1;
  }
  else{
_carts.add(CartModel(grocery: grocery, quantity: 1));
  }
  notifyListeners();
}
void addQuality(Map<String,dynamic>grocery)
{
 int index=_carts.indexWhere((element)=>element.grocery['id']==grocery['id']);
 if(index!=-1)
 {
  _carts[index].quantity=_carts[index].quantity+1;
  notifyListeners();
 }
}
void reduceQuality(Map<String,dynamic>grocery)
{
 int index=_carts.indexWhere((element)=>element.grocery['id']==grocery['id']);
 if(index!=-1)
 {
  _carts[index].quantity=_carts[index].quantity-1;
  notifyListeners();
 }
 else if(index !=-1 && _carts[index].quantity==1){

 }
}
bool productExits(Map<String,dynamic>grocery)
{
  return _carts.indexWhere((element)=>element.grocery['id']==grocery['id'])!=-1;
 
}
void removeFromCart(Map<String,dynamic>grocery)
{
  int index=_carts.indexWhere((element)=>element.grocery['id']==grocery['id']);
  if(index!=-1)
  {
_carts.removeAt(index);
notifyListeners();
  }
}

double totalCart(){
  double total=0;
  for(var i=0;i<_carts.length;i++)
  {
    total+=_carts[i].quantity*double.parse(_carts[i].grocery['price'].toString());
  }
  return total;
}
}