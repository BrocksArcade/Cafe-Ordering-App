// order_details_screen.dart
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';


class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  final Cafe cafe;
  const OrderDetailsScreen({Key? key, required this.order, required this.cafe})
      : super(key: key);

  double _calculateTotal(Order order) {
    double total = 0.0;
    for (var item in order.foodItems) {
      total += item.price * item.qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal(order);
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.id} Details'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cafe Details
            Text(
              cafe.name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(cafe.address),
            Text('Contact: ${cafe.contactNumber}'),
            const Divider(),
            const Text(
              'Order Details',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: order.foodItems.length,
                itemBuilder: (context, index) {
                  final item = order.foodItems[index];
                  return ListTile(
                    title: Text(item.foodDisplayName),
                    subtitle: Text("Qty: ${item.qty}"),
                    trailing: Text(
                        "\$${(item.price * item.qty).toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Total'),
              trailing: Text("\$${total.toStringAsFixed(2)}"),
            ),
          ],
        ),
      ),
    );
  }
}
