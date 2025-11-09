import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  final CollectionReference categoryRef =
      FirebaseFirestore.instance.collection('Category');

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        title: const Text("Manage Categories"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Category",
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index].data() as Map<String, dynamic>;
              final docId = categories[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: ListTile(
                  leading: category['image'] != null
                      ? Image.network(category['image'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(category['name'] ?? 'Unnamed Category'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(existingDoc: categories[index]);
                      } else if (value == 'delete') {
                        _confirmDelete(docId, category['name']);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('Edit Category')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete Category')),
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

  Future<void> _showAddEditDialog({DocumentSnapshot? existingDoc}) async {
    final nameController =
        TextEditingController(text: existingDoc?['name'] ?? '');
    String? imageUrl = existingDoc?['image'];
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text(existingDoc == null
                ? "Add New Category"
                : "Update Category"),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
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
                  decoration: const InputDecoration(labelText: "Category Name"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a name")),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  setState(() => _loading = true);

                  try {
                    if (imageFile != null) {
                      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
                      final uploadPreset =
                          dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
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
                      imageUrl = data['secure_url'];
                    }

                    final categoryData = {
                      'name': name,
                      'image': imageUrl,
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    if (existingDoc != null) {
                      await categoryRef.doc(existingDoc.id).update(categoryData);
                    } else {
                      await categoryRef.add({
                        ...categoryData,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(existingDoc == null
                            ? "✅ Category added successfully!"
                            : "✅ Category updated successfully!")));
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

  Future<void> _confirmDelete(String id, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text("Are you sure you want to delete \"$name\"?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await categoryRef.doc(id).delete();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🗑 Category deleted")));
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
