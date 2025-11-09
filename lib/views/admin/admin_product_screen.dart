import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  bool _loading = false;
  final CollectionReference productsRef =
      FirebaseFirestore.instance.collection('myAppCollection');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        title: const Text("Manage Products"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Product",
            onPressed: () => _showAddEditDialog(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final docId = products[index].id;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  leading: product['image'] != null
                      ? Image.network(product['image'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(product['name'] ?? 'Unnamed'),
                  subtitle:
                      Text("৳${product['price']}  •  ${product['category']}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(existingDoc: products[index]);
                      } else if (value == 'delete') {
                        _confirmDelete(docId, product['name']);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Edit Product')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete Product')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ✅ Add or Edit product dialog
  Future<void> _showAddEditDialog({DocumentSnapshot? existingDoc}) async {
    final nameController =
        TextEditingController(text: existingDoc?['name'] ?? '');
    final priceController =
        TextEditingController(text: existingDoc?['price']?.toString() ?? '');
    final categoryController =
        TextEditingController(text: existingDoc?['category'] ?? '');
    final descriptionController =
        TextEditingController(text: existingDoc?['description'] ?? '');
    String? imageUrl = existingDoc?['image'];

    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(existingDoc == null
                ? "Add New Product"
                : "Update Product"),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (picked != null) {
                        setModalState(() {
                          imageFile = File(picked.path);
                        });
                      }
                    },
                    child: imageFile != null
                        ? Image.file(imageFile!,
                            width: 120, height: 120, fit: BoxFit.cover)
                        : (imageUrl != null
                            ? Image.network(imageUrl!,
                                width: 120, height: 120, fit: BoxFit.cover)
                            : Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.add_a_photo,
                                    color: Colors.grey),
                              )),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Product Name"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: "Description"),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final price = double.tryParse(priceController.text.trim());
                  final category = categoryController.text.trim();
                  final description = descriptionController.text.trim();

                  if (name.isEmpty || price == null || category.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill in all required fields")),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  setState(() => _loading = true);

                  try {
                    // ✅ Upload image to Cloudinary if new image picked
                    if (imageFile != null) {
                      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
                      final uploadPreset =
                          dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      final fileName = "products/$timestamp.jpg";

                      final url = Uri.parse(
                          "https://api.cloudinary.com/v1_1/$cloudName/image/upload");
                      final request = http.MultipartRequest('POST', url)
                        ..fields['upload_preset'] = uploadPreset!
                        ..files.add(await http.MultipartFile.fromPath(
                            'file', imageFile!.path));

                      final response = await request.send();
                      final responseData =
                          await http.Response.fromStream(response);
                      final data = jsonDecode(responseData.body);
                      if (data['secure_url'] != null) {
                        imageUrl = data['secure_url'];
                      }
                    }

                    // ✅ Prepare Firestore data
                    final productData = {
                      'name': name,
                      'price': price,
                      'category': category,
                      'description': description,
                      'image': imageUrl,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    // ✅ Update or Add new
                    if (existingDoc != null) {
                      await productsRef.doc(existingDoc.id).update(productData);
                    } else {
                      await productsRef.add({
                        ...productData,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(existingDoc == null
                              ? "✅ Product added successfully!"
                              : "✅ Product updated successfully!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("⚠️ Error: $e")),
                    );
                  } finally {
                    setState(() => _loading = false);
                  }
                },
                child: Text(existingDoc == null ? "Add" : "Update"),
              ),
            ],
          );
        });
      },
    );
  }

  /// 🗑 Confirm delete before deleting
  Future<void> _confirmDelete(String id, String name) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: Text("Are you sure you want to delete \"$name\"?"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await _deleteProduct(id);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  /// 🗑 Delete product
  Future<void> _deleteProduct(String id) async {
    try {
      await productsRef.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑 Product deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Failed to delete product: $e")),
      );
    }
  }
}
