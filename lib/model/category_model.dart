import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void>uploadCategoryDataFirestore()async{
  final CollectionReference ref =FirebaseFirestore.instance.collection("Category");
  for(final CategoryModel item in grocerieCategory)
  {
    final String id=DateTime.now().toIso8601String()+Random().nextInt(1000).toString();
    await ref.doc(id).set(item.toMap());
  }
}
class CategoryModel {
  String image;
  String name;
  CategoryModel({
    required this.image,
    required this.name,
  }
  );
  Map<String ,dynamic>toMap()
  {
    return {
      'image':image,
      'name':name,
    };
  }
}

List<CategoryModel> grocerieCategory = [
  // 🥩 MEAT
  CategoryModel(

    image:
        "https://www.themeateater.com/sites/default/files/styles/article_full_width_image/public/2022-10/Beef_Cuts.jpg",
    name: "MEAT",
  ),


  // 🌶️ SPICES
  CategoryModel(
    image:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Turmeric_powder.jpg/800px-Turmeric_powder.jpg",
    name: "SPICES",
  ),

  // 🍞 
  CategoryModel(
    image:
        "https://upload.wikimedia.org/wikipedia/commons/d/d5/Loaf-english-muffin-bread.jpg",
    name: "BAKERY",
  ),

  // 🥦 VEGETABLES
  CategoryModel(
    image:
        "https://upload.wikimedia.org/wikipedia/commons/3/3a/Broccoli_and_cross_section_edit.jpg",
    name: "VEGETABLES",
),

  // 🍓 
  CategoryModel(
    image:
        "https://cdn.mos.cms.futurecdn.net/uAWeWfDQVrFPdCgKmgZhX.jpg",
    name: "FRUITS",
  ),
];
