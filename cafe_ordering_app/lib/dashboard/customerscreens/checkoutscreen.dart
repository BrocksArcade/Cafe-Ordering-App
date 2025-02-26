// checkout_screen.dart
import 'package:appwrite/appwrite.dart';
import 'package:cafe_ordering_app/Netowkrs/AppwriteService.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Food> cartItems;
  final Cafe cafe;
  const CheckoutScreen({Key? key, required this.cartItems, required this.cafe})
      : super(key: key);

  double _calculateTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.price;
    }
    return total;
  }

  // Placeholder to "place" the order.
  void _placeOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thank You!"),
        content: const Text("Your order has been placed."),
        actions: [
          TextButton(
            onPressed: () async {
              Order order = Order(
                  id: ID.unique(),
                  menuID: "",
                  userid: await Appwriteservice().getUserID(),
                  status: 'Preparing');
              if (order.userid.isEmpty) {
                Appwriteservice()
                    .showErrorDialogWContext(context, "User ID Invalid");
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              else{
                await Appwriteservice().placeOrder(order, cafe);
              }
              // Pop all screens and return to the home screen.

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    title: Text(item.foodDisplayName),
                    subtitle:
                        Text("Qty: ${item.qty.toString()} * ${item.price}"),
                    trailing: Text("${item.price * item.qty}"),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Total'),
              trailing: Text("\$${total.toStringAsFixed(2)}"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _placeOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text(
                "Place Order",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
