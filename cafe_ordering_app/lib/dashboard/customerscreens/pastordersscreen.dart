// pastOrdersScreen.dart
import 'package:cafe_ordering_app/dashboard/customerscreens/orderdetailsscreen.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class PastOrdersScreen extends StatelessWidget {
  final List<Order> orders;
  final Cafe cafe; // For demonstration, assuming all orders belong to this cafe.
  const PastOrdersScreen({Key? key, required this.orders, required this.cafe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Orders'),
        backgroundColor: Colors.pink,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No past orders found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text("Order ${order.id}"),
                    subtitle: Text("Status: ${order.status}"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(
                            order: order,
                            cafe: cafe,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
