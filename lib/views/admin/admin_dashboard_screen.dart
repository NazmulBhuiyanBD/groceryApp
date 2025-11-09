import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/views/admin/admin_product_screen.dart';
import 'package:grocery_app/views/admin/admin_user_screen.dart';
import 'package:grocery_app/views/admin/admin_category_screen.dart';
import 'package:grocery_app/views/admin/admin_order_screen.dart';
import 'package:grocery_app/views/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalProducts = 0;
  int _totalUsers = 0;
  int _totalCategories = 0;
  int _totalOrders = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      final productsSnap =
          await FirebaseFirestore.instance.collection('myAppCollection').get();
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      final categorySnap =
          await FirebaseFirestore.instance.collection('Category').get();
      final ordersSnap =
          await FirebaseFirestore.instance.collection('orders').get();

      setState(() {
        _totalProducts = productsSnap.size;
        _totalUsers = usersSnap.docs
            .where((doc) =>
                doc.data().containsKey('isAdmin') && doc['isAdmin'] == false)
            .length;
        _totalCategories = categorySnap.size;
        _totalOrders = ordersSnap.size;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠️ Failed to load data: $e")));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: secondarycolor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.78, // ✅ slightly smaller for safe fit
                      children: [
                        _buildDashboardCard(
                          title: "Products",
                          count: _totalProducts,
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.blue.shade700,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminProductScreen()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: "Users",
                          count: _totalUsers,
                          icon: Icons.people_alt_outlined,
                          color: Colors.green.shade700,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminUserScreen()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: "Categories",
                          count: _totalCategories,
                          icon: Icons.category_outlined,
                          color: Colors.orange.shade700,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminCategoryScreen()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          title: "Orders",
                          count: _totalOrders,
                          icon: Icons.receipt_long_outlined,
                          color: Colors.red.shade700,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AdminOrderScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onViewAll,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(foregroundColor: color),
              child: Text(
                "View All",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
