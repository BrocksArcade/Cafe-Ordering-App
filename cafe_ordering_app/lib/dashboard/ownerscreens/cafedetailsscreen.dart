// cafe_details_screen.dart
import 'package:cafe_ordering_app/dashboard/ownerscreens/managemenusscreen.dart';
import 'package:cafe_ordering_app/dashboard/ownerscreens/manageordersscreen.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';


class CafeDetailsScreen extends StatefulWidget {
  final Cafe cafe;
  const CafeDetailsScreen({super.key, required this.cafe});

  @override
  _CafeDetailsScreenState createState() => _CafeDetailsScreenState();
}

class _CafeDetailsScreenState extends State<CafeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  double _calculateTotalPrice(Order order) {
    double total = 0.0;
    for (var food in order.foodItems) {
      total += food.price * food.qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cafe.name),
        backgroundColor: Colors.pink,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Orders"),
            Tab(text: "Menus"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Orders Tab
          ListView.builder(
            itemCount: widget.cafe.orders.length,
            itemBuilder: (context, index) {
              final order = widget.cafe.orders[index];
              return Card(
                child: ListTile(
                  title: Text("Order ${order.id}"),
                  subtitle: Text(
                      "Total: \$${_calculateTotalPrice(order).toStringAsFixed(2)}"),
                  trailing: Text(
                    order.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Navigate to Manage Orders Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageOrdersScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Menus Tab
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Manage Menus Screen in "add" mode
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageMenusScreen(cafe: widget.cafe),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Menu Category"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.cafe.menus.length,
                  itemBuilder: (context, index) {
                    final menu = widget.cafe.menus[index];
                    return Card(
                      child: ListTile(
                        title: Text(menu.name),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to Manage Menus Screen in "edit" mode
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageMenusScreen(
                                cafe: widget.cafe,
                                menu: menu,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
