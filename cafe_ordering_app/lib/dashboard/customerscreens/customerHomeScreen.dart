// customer_home_screen.dart
import 'package:cafe_ordering_app/Netowkrs/AppwriteService.dart';
import 'package:cafe_ordering_app/dashboard/customerscreens/orderdetailsscreen.dart';
import 'package:cafe_ordering_app/dashboard/customerscreens/orderingScreen.dart';

import 'package:cafe_ordering_app/dashboard/customerscreens/pastCafesScreen.dart';
import 'package:cafe_ordering_app/dashboard/customerscreens/pastOrdersScreen.dart';
import 'package:cafe_ordering_app/dashboard/customerscreens/qrcodescanner.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // Dummy orders list for demonstration.
  List<Order> orders = [];
  // List for past scanned cafes.
  List<Cafe> pastCafes = [];
  // When a QR code is scanned, the corresponding cafe details are stored here.
  // Return only active orders (not "Completed").
  List<Order> get activeOrders =>
      orders.where((order) => order.status != 'Completed').toList();

  // Return past orders (those with status "Completed").
  List<Order> get pastOrders =>
      orders.where((order) => order.status == 'Completed').toList();

  Cafe? scannedCafe;
  @override
  void reassemble() {
    super.reassemble();
  }

  @protected
  @mustCallSuper
  void didPopNext(Route<dynamic> nextRoute) {
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    orders = [];
    getPastOrders();
  }

  Future<void> getPastOrders() async {
    orders = await Appwriteservice()
        .fetchAllOrdersByUserID(await Appwriteservice().getUserID());
    setState(() {});
  }

  // Simulate QR code scanning.
  void _scanQRCode() async {
    var barcode = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));

    scannedCafe = await Appwriteservice().fetchCafeById(barcode);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderingScreen(cafe: scannedCafe!)));
    if (scannedCafe == null) {
      Appwriteservice().showErrorDialogWContext(context, "Incorrect QR Code");
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Appwriteservice.logout(context),
        child: const Icon(
          Icons.logout_rounded,
          color: Colors.pinkAccent,
        ),
      ),
      appBar: AppBar(
        title: const Text('Customer Home'),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              // Active Orders Section with a distinct background.
              if (activeOrders.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Orders',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeOrders.length,
                        itemBuilder: (context, index) {
                          final order = activeOrders[index];
                          return Card(
                            child: ListTile(
                              title: Text("Order ${order.id}"),
                              subtitle: Text("Status: ${order.status}"),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () {
                                // Navigate to a read-only order details screen.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsScreen(
                                        order: order, cafe: scannedCafe!),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Scan Menu Option
              ElevatedButton.icon(
                onPressed: _scanQRCode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
              ),
              const SizedBox(height: 24),
              // View Past Cafes Option
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PastCafesScreen(cafes: pastCafes),
                    ),
                  );
                },
                icon: const Icon(Icons.store),
                label: const Text('View Past Cafes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
              ),
              const SizedBox(height: 24),
              // View Past Orders Option
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PastOrdersScreen(
                        orders: pastOrders,
                        cafe: scannedCafe ??
                            Cafe(
                              userId: "",
                              id: 'unknown',
                              name: 'Unknown Cafe',
                              address: '',
                              contactNumber: '',
                              menus: [],
                              orders: [],
                            ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('View Past Orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
