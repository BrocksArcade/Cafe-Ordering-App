import 'package:cafe_ordering_app/dashboard/customerscreens/checkoutscreen.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class OrderingScreen extends StatefulWidget {
  final Cafe cafe;
  const OrderingScreen({super.key, required this.cafe});

  @override
  _OrderingScreenState createState() => _OrderingScreenState();
}

class _OrderingScreenState extends State<OrderingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Food> cart = [];

  // Set to track which food items have been added to the cart.
  final Set<String> _addedFoodIds = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.cafe.menus.length, vsync: this);
    // Initialize default quantity for each food item to 1 if not set.
    for (var menu in widget.cafe.menus) {
      for (var food in menu.foodItems) {
        if (food.qty < 1) {
          food.qty = 1;
        }
      }
    }
  }

  // Update quantity for a specific food item by modifying its 'qty' property.
  void _updateQuantity(Food food, int change) {
    setState(() {
      int newQty = food.qty + change;
      if (newQty < 1) newQty = 1;
      food.qty = newQty;
      // If the food is already in the cart, update its quantity there as well.
      int index = cart.indexWhere((f) => f.itemID == food.itemID);
      if (index != -1) {
        cart[index].qty = newQty;
      }
    });
  }

  // Add a food item to the cart.
  void _addToCart(Food food) {
    setState(() {
      // If the food is not already added, add a copy of it to the cart.
      if (!_addedFoodIds.contains(food.itemID)) {
        // Create a new Food instance (or clone) with the current quantity.
        Food foodCopy = Food(
          itemID: food.itemID,
          foodDisplayName: food.foodDisplayName,
          price: food.price,
          qty: food.qty,
          description: food.description,
        );
        cart.add(foodCopy);
        _addedFoodIds.add(food.itemID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cafe.name} Menu'),
        backgroundColor: Colors.pink,
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.cafe.menus.map((menu) => Tab(text: menu.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.cafe.menus.map((menu) {
          return ListView.builder(
            itemCount: menu.foodItems.length,
            itemBuilder: (context, index) {
              final food = menu.foodItems[index];
              bool isAdded = _addedFoodIds.contains(food.itemID);
              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(food.foodDisplayName),
                      subtitle: Text("\$${food.price.toStringAsFixed(2)}"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Qty: "),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () => _updateQuantity(food, -1),
                          ),
                          Text(
                            food.qty.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () => _updateQuantity(food, 1),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: isAdded ? null : () => _addToCart(food),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isAdded ? Colors.grey : Colors.redAccent,
                            ),
                            child: Text(isAdded ? "Added" : "Add"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to checkout screen, passing the cart and cafe details.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CheckoutScreen(cartItems: cart, cafe: widget.cafe),
                  ),
                );
              },
              label: const Text("Checkout"),
              icon: const Icon(Icons.shopping_cart),
              backgroundColor: Colors.orange,
            )
          : null,
    );
  }
}
