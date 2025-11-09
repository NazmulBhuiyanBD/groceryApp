import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/constrain.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final List<String> statuses = const [
    'Pending',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  String _normalizeStatus(String? value) {
    if (value == null) return 'Pending';
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'pending':
        return 'Pending';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondarycolor,
      appBar: AppBar(
        title: const Text("Manage Orders"),
        backgroundColor: secondarycolor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("⚠️ Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No orders found.",
                    style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final docId = orders[index].id;

              final userEmail = data['userEmail'] ?? 'Unknown User';
              final address = data['address'] ?? 'No address';
              final total = data['total'] ?? 0.0;
              final status = _normalizeStatus(data['status']);
              final orderDate = data['orderDate'] != null
                  ? (data['orderDate'] as Timestamp).toDate()
                  : null;

              final items = (data['items'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.receipt_long_outlined,
                      color: Colors.green),
                  title: Text(
                    "Order #${docId.substring(0, 6)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User: $userEmail"),
                      Text("Total: ৳${total.toStringAsFixed(2)}"),
                      Text("Status: $status",
                          style: TextStyle(
                              color: status == 'Pending'
                                  ? Colors.orange
                                  : status == 'Delivered'
                                      ? Colors.green
                                      : status == 'Cancelled'
                                          ? Colors.red
                                          : Colors.blue)),
                      if (orderDate != null)
                        Text(
                            "Date: ${orderDate.day}/${orderDate.month}/${orderDate.year}"),
                    ],
                  ),
                  children: [
                    // 🛒 Ordered items list
                    ...items.map((item) => ListTile(
                          title: Text(item['name'] ?? 'Unknown item'),
                          subtitle: Text(
                              "৳${item['price']} × ${item['quantity']} = ৳${(item['price'] * item['quantity']).toStringAsFixed(2)}"),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text("Address: $address",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        value: statuses.contains(status) ? status : 'Pending',
                        decoration: const InputDecoration(
                          labelText: "Update Status",
                          border: OutlineInputBorder(),
                        ),
                        items: statuses
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (newStatus) async {
                          if (newStatus != null &&
                              newStatus != data['status']) {
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(docId)
                                .update({
                              'status': newStatus,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "✅ Order updated to $newStatus")));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
