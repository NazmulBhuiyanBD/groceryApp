import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/widget/info_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grocery_app/services/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  Map<String, dynamic>? userInfo;

  File? _imageFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      setState(() {
        userInfo = doc.data();
      });
    }
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _showUpdateDialog() {
    final nameController = TextEditingController(text: userInfo?['name'] ?? '');
    final phoneController = TextEditingController(text: userInfo?['phone'] ?? '');
    final addressController = TextEditingController(text: userInfo?['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Profile"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
                const SizedBox(height: 8),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
                const SizedBox(height: 8),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  addressController.text.trim(),
                );
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile(String name, String phone, String address) async {
    if (user == null) return;
    setState(() => _loading = true);

    String? photoUrl = userInfo?['photoURL'];

    if (_imageFile != null) {
      final ref = FirebaseStorage.instance.ref().child('user_photos/${user!.uid}.jpg');
      await ref.putFile(_imageFile!);
      photoUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'phone': phone,
      'address': address,
      'photoURL': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await user!.updateDisplayName(name);
    if (photoUrl != null) await user!.updatePhotoURL(photoUrl);

    await _loadUserInfo();
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Profile updated successfully")));
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Center(child: Text("No user signed in"));
    if (userInfo == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: secondarycolor,
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (userInfo?['photoURL'] != null
                                ? NetworkImage(userInfo!['photoURL'])
                                : const AssetImage('assets/profile.png')) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor:primarycolor,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(userInfo?['name'] ?? "User", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  const Divider(),
                  InfoCard(title:"Email",value: user!.email ?? "N/A"),
                  InfoCard(title:"Phone",value: userInfo?['phone'] ?? "N/A"),
                  InfoCard(title:"Address",value: userInfo?['address'] ?? "N/A"),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: _showUpdateDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile",style: TextStyle(color: secondarycolor),),
                    style: ElevatedButton.styleFrom(backgroundColor: primarycolor,iconColor: secondarycolor),
                  ),
                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Previous Orders",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildOrderHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderHistory() {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user!.uid)
          // .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No previous orders found.");
        }

        final orders = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text("Order #${orders[index].id.substring(0, 6)}"),
                subtitle: Text("Total: \$${order['total'] ?? 0.0}"),
                trailing: Text(order['status'] ?? 'Pending', style: const TextStyle(color: Colors.blue)),
              ),
            );
          },
        );
      },
    );
  }
}
