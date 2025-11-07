import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/widget/info_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      setState(() {
        userInfo = doc.data();
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _loading = true;
      _uploadProgress = 0;
    });

    try {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

      if (cloudName == null || uploadPreset == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("⚠️ Cloudinary credentials not found. Check .env file.")),
        );
        return;
      }

      print("🧩 CLOUDINARY NAME: $cloudName");
      print("🧩 UPLOAD PRESET: $uploadPreset");

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = "${user!.uid}_$timestamp";

      final url =
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final fileLength = await _imageFile!.length();
      final stream = _imageFile!.openRead();
      int bytesSent = 0;

      final transformedStream = stream.transform<List<int>>(
        StreamTransformer.fromHandlers(
          handleData: (List<int> chunk, EventSink<List<int>> sink) {
            bytesSent += chunk.length;
            setState(() {
              _uploadProgress = bytesSent / fileLength;
            });
            sink.add(chunk);
          },
          handleError: (error, stackTrace, sink) =>
              sink.addError(error, stackTrace),
          handleDone: (sink) => sink.close(),
        ),
      );

      final multipartFile = http.MultipartFile(
        'file',
        http.ByteStream(transformedStream),
        fileLength,
        filename: picked.name,
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = "users/$uniqueFileName"
        ..files.add(multipartFile);


      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = jsonDecode(responseData.body);

      if (data['secure_url'] == null) {
        throw Exception('Upload failed: no URL returned from Cloudinary.');
      }

      final imageUrl = data['secure_url'];


      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'photoURL': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user!.updatePhotoURL(imageUrl);

      await _loadUserInfo();

      setState(() {
        _loading = false;
        _uploadProgress = 0;
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile photo updated successfully")),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Cloudinary upload failed: $e")),
      );
    }
  }

  void _showUpdateDialog() {
    final nameController = TextEditingController(text: userInfo?['name'] ?? '');
    final phoneController =
        TextEditingController(text: userInfo?['phone'] ?? '');
    final addressController =
        TextEditingController(text: userInfo?['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Profile"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Full Name")),
                const SizedBox(height: 8),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone")),
                const SizedBox(height: 8),
                TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: "Address")),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
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

  Future<void> _updateProfile(
      String name, String phone, String address) async {
    if (user == null) return;
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'name': name,
        'phone': phone,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user!.updateDisplayName(name);

      await _loadUserInfo();

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully")),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Failed to update profile: $e")),
      );
    }
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Uploading your Information...",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 25),
                  ModernProgressBar(progress: _uploadProgress),
                  const SizedBox(height: 25),
                  Text(
                    _uploadProgress >= 1
                        ? "✅ Completed!"
                        : "Uploading... please wait",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (userInfo?['photoURL'] != null
                                ? NetworkImage(userInfo!['photoURL'])
                                : const AssetImage('assets/profile.png'))
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: primarycolor,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(userInfo?['name'] ?? "User",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Divider(),
                  InfoCard(title: "Email", value: user!.email ?? "N/A"),
                  InfoCard(title: "Phone", value: userInfo?['phone'] ?? "N/A"),
                  InfoCard(title: "Address", value: userInfo?['address'] ?? "N/A"),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showUpdateDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(color: secondarycolor),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primarycolor,
                      iconColor: secondarycolor,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Previous Orders",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
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
                trailing: Text(order['status'] ?? 'Pending',
                    style: const TextStyle(color: Colors.blue)),
              ),
            );
          },
        );
      },
    );
  }
}

class ModernProgressBar extends StatelessWidget {
  final double progress;

  const ModernProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 20,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 20,
          width: 250 * progress.clamp(0, 1),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        Text(
          "$percentage%",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
