import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/provider/Model/cart_model.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/utils/constrain.dart';
import 'package:grocery_app/widget/cart_items.dart';
import 'package:grocery_app/views/profile_page.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? deliveryAddress;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
  }

  Future<void> _fetchUserAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        deliveryAddress = null;
        _loadingAddress = false;
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()?['address'] != null) {
      setState(() {
        deliveryAddress = doc['address'];
        _loadingAddress = false;
      });
    } else {
      setState(() {
        deliveryAddress = null;
        _loadingAddress = false;
      });
    }
  }

  Future<void> _proceedToCheckout(
      CartProvider cartProvider, double totalAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Check if user has address
    if (deliveryAddress == null || deliveryAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please update your delivery address first."),
          backgroundColor: Colors.redAccent,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }

    final orderData = {
      'userId': user.uid,
      'userEmail': user.email,
      'orderDate': FieldValue.serverTimestamp(),
'items': cartProvider.carts.map((item) => {
      'productId': item.grocery['id'],
      'name': item.grocery['name'],
      'price': item.grocery['price'],
      'quantity': item.quantity,
    }).toList(),
      'total': totalAmount,
      'address': deliveryAddress,
      'status': 'Pending',
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);

    cartProvider.carts = [];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Order placed successfully!"),
        backgroundColor:primarycolor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartModel> carts = cartProvider.carts.reversed.toList();
    final Size size = MediaQuery.of(context).size;

    final double deliveryCharge = 4.99;
    final double total =
        cartProvider.totalCart() + deliveryCharge + 0.1 * carts.length;

    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        backgroundColor: secondarycolor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _loadingAddress
            ? const Center(child: CircularProgressIndicator())
            : carts.isEmpty
                ? const Center(
                    child: Text("Your cart is empty",style: TextStyle(fontSize: 18),),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: size.height * 0.5,
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            carts.length,
                            (index) => SizedBox(
                              height: 100,
                              width: size.width,
                              child: CartItems(cart: carts[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
      bottomSheet: carts.isEmpty
          ? null
          : Container(
              color: secondarycolor,
              height: size.height * 0.37,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${cartProvider.totalCart().toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primarycolor),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        "Delivery Charge",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        "\$$deliveryCharge",
                        style: TextStyle(
                            color: primarycolor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery Address:",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()),
                            );
                          },
                          child: Text(
                            deliveryAddress ??
                                "No address found (Tap to update)",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              color: deliveryAddress == null
                                  ? Colors.red
                                  : Colors.black87,
                              fontStyle: deliveryAddress == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Price",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${total.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primarycolor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () => _proceedToCheckout(cartProvider, total),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: primarycolor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.7),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Proceed to Checkout",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
