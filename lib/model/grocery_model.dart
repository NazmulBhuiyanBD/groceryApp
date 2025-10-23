import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void>uploadDataFirestore()async{
  final CollectionReference ref =FirebaseFirestore.instance.collection("myAppCollection");
  for(final GroceryModel item in groceries)
  {
    final String id=DateTime.now().toIso8601String()+Random().nextInt(1000).toString();
    final GroceryModel itemwithId=GroceryModel(
      id:id,
      image:item.image,
      name:item.name,
      price:item.price,
      rating:item.rating,
      description:item.description,
      category:item.category,
    );
    await ref.doc(id).set(itemwithId.toMap());
  }
}
final docRef=FirebaseFirestore.instance.collection('groceries').doc();
class GroceryModel {
  String id;
  String image;
  String name;
  dynamic price;
  double rating;
  List<String>?description;
  String category;
  GroceryModel({
    required this.id,
    required this.image,
    required this.name,
    required this.price , 
    required this.rating ,
     required this.description ,
      required this.category ,
  }
  );
  Map<String ,dynamic>toMap()
  {
    return {
      'id':id,
      'image':image,
      'name':name,
      'price':price,
      'rating':rating,
      'description':description,
      'category':category,
    };
  }
}

List<GroceryModel> groceries = [
  // 🥩 MEAT
  GroceryModel(
    id: '',
    image:
        "https://www.allrecipes.com/thmb/CJPx_AO4aBs5EJo11N_D9o3Iwpg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Cuts-of-Beef-2x1-1-859c2a9b8aaf4c3cb747ed0f5025a496.png",
    name: "Chicken Breast",
    price: 5.9,
    rating: 4.5,
    description: [
      "Lean and tender chicken breast",
      "- High in protein and low in fat",
      "- Perfect for a healthy diet",
    ],
    category: "Meat",
  ),
  GroceryModel(
    id: '',
    image:
        "https://www.themeateater.com/sites/default/files/styles/article_full_width_image/public/2022-10/Beef_Cuts.jpg",
    name: "Beef Steak",
    price: 12.5,
    rating: 4.7,
    description: [
      "Juicy, tender beef steak",
      "- Ideal for grilling or pan-searing",
      "- Rich in iron and flavor",
    ],
    category: "Meat",
  ),
  GroceryModel(
    id: '',
    image:
        "https://cdn.thewirecutter.com/wp-content/media/2022/11/fishforsushi-2048px-salmon-2x1-1.jpg",
    name: "Fresh Salmon",
    price: 10.9,
    rating: 4.9,
    description: [
      "Fresh Atlantic salmon fillet",
      "- Great source of Omega-3",
      "- Perfect for grilling or baking",
    ],
    category: "Meat",
  ),

  // 🌶️ SPICES
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Turmeric_powder.jpg/800px-Turmeric_powder.jpg",
    name: "Turmeric Powder",
    price: 1.5,
    rating: 4.8,
    description: [
      "Pure organic turmeric powder",
      "- Adds color and flavor",
      "- Known for anti-inflammatory benefits",
    ],
    category: "Spices",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/4/4b/Black_pepper.jpg",
    name: "Black Pepper",
    price: 2.0,
    rating: 4.7,
    description: [
      "Whole black pepper seeds",
      "- Sharp and spicy flavor",
      "- Perfect for seasoning meats and soups",
    ],
    category: "Spices",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cinnamon.jpg",
    name: "Cinnamon Sticks",
    price: 1.8,
    rating: 4.6,
    description: [
      "Natural aromatic cinnamon sticks",
      "- Great for desserts and tea",
      "- Enhances warmth and sweetness",
    ],
    category: "Spices",
  ),

  // 🍞 BAKERY
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/d/d5/Loaf-english-muffin-bread.jpg",
    name: "Whole Wheat Bread",
    price: 2.5,
    rating: 4.4,
    description: [
      "Soft and fresh whole wheat bread",
      "- High in fiber",
      "- Perfect for breakfast and sandwiches",
    ],
    category: "Bakery",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/1/12/Croissant-Petr-Kratochvil.jpg",
    name: "Butter Croissant",
    price: 1.2,
    rating: 4.9,
    description: [
      "Flaky and buttery French croissant",
      "- Great with coffee",
      "- Freshly baked every morning",
    ],
    category: "Bakery",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/0/09/Chocolate_chip_cookies.jpg",
    name: "Chocolate Chip Cookies",
    price: 3.5,
    rating: 4.8,
    description: [
      "Crispy and chewy chocolate chip cookies",
      "- Made with real butter and dark chocolate",
      "- Perfect for snacks and desserts",
    ],
    category: "Bakery",
  ),

  // 🥦 VEGETABLES
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/3/3a/Broccoli_and_cross_section_edit.jpg",
    name: "Broccoli",
    price: 2.3,
    rating: 4.5,
    description: [
      "Fresh organic broccoli",
      "- Rich in vitamins and fiber",
      "- Perfect for steaming or stir-frying",
    ],
    category: "Vegetables",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/c/c4/Carrots.jpg",
    name: "Carrots",
    price: 1.8,
    rating: 4.6,
    description: [
      "Crisp and sweet carrots",
      "- Great for salads and soups",
      "- High in Vitamin A",
    ],
    category: "Vegetables",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/9/9d/Tomato_je.jpg",
    name: "Tomatoes",
    price: 1.5,
    rating: 4.7,
    description: [
      "Fresh red tomatoes",
      "- Juicy and flavorful",
      "- Great for sauces and salads",
    ],
    category: "Vegetables",
  ),

  // 🍓 FRUITS
  GroceryModel(
    id: '',
    image:
        "https://cdn.mos.cms.futurecdn.net/uAWeWfDQVrFPdCgKmgZhX.jpg",
    name: "Blueberries",
    price: 3.9,
    rating: 4.8,
    description: [
      "Fresh organic blueberries",
      "- Packed with antioxidants",
      "- Great for smoothies and snacks",
    ],
    category: "Fruits",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg",
    name: "Apple",
    price: 2.9,
    rating: 4.9,
    description: [
      "Crisp and juicy red apples",
      "- High in fiber and vitamin C",
      "- Perfect healthy snack",
    ],
    category: "Fruits",
  ),
  GroceryModel(
    id: '',
    image:
        "https://upload.wikimedia.org/wikipedia/commons/9/9b/Strawberries.jpg",
    name: "Strawberries",
    price: 4.2,
    rating: 4.9,
    description: [
      "Sweet and fresh strawberries",
      "- Great for desserts and smoothies",
      "- Naturally rich in Vitamin C",
    ],
    category: "Fruits",
  ),
];
