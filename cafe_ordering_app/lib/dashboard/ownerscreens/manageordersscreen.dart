// manage_orders_screen.dart
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';


class ManageOrdersScreen extends StatefulWidget {
  final Order order;
  const ManageOrdersScreen({super.key, required this.order});

  @override
  _ManageOrdersScreenState createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  // Update the order status (placeholder logic)
  void _updateStatus() {
    setState(() {
      widget.order.status = _selectedStatus!;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Order ${widget.order.id}"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.order.foodItems.length,
                itemBuilder: (context, index) {
                  final food = widget.order.foodItems[index];
                  return ListTile(
                    title: Text(food.foodDisplayName),
                    subtitle: Text(
                        "Price: \$${food.price.toStringAsFixed(2)} | Qty: ${food.qty}"),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Change Order Status:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedStatus,
              items: <String>['Preparing', 'Dispatched', 'Completed']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _updateStatus,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Update Order"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
