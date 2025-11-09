import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';

class AdminUserScreen extends StatelessWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        title: const Text("All Users"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isAdmin', isEqualTo: false) // ✅ Show only customers
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['photoURL'] != null
                      ? NetworkImage(user['photoURL'])
                      : const AssetImage('assets/profile.png') as ImageProvider,
                ),
                title: Text(user['name'] ?? 'Unknown'),
                subtitle: Text(user['email'] ?? 'No email'),
              );
            },
          );
        },
      ),
    );
  }
}
