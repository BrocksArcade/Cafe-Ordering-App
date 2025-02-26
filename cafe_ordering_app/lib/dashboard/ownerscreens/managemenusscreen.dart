// manage_menus_screen.dart
import 'package:appwrite/appwrite.dart';
import 'package:cafe_ordering_app/Netowkrs/AppwriteService.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class ManageMenusScreen extends StatefulWidget {
  final Cafe cafe;
  final Menu? menu; // If null, then we're creating a new menu
  const ManageMenusScreen({super.key, required this.cafe, this.menu});

  @override
  _ManageMenusScreenState createState() => _ManageMenusScreenState();
}

class _ManageMenusScreenState extends State<ManageMenusScreen> {
  final _menuNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();

  List<Food> foodItems = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // If editing an existing menu, fetch its latest details from the database.
    if (widget.menu != null) {
      setState(() {
        _menuNameController.text = widget.menu!.name;
        foodItems = List.from(widget.menu!.foodItems);
      });
    }
  }

  // Add a new food item to the local list (no immediate DB push)
  void _addFoodItem() {
    if (_foodNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _qtyController.text.isEmpty) {
      return;
    }
    final newFood = Food(
      itemID: DateTime.now().millisecondsSinceEpoch.toString(),
      foodDisplayName: _foodNameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 10,
      description: _descriptionController.text,
      qty: int.tryParse(_qtyController.text) ?? 1,
    );
    setState(() {
      foodItems.add(newFood);
    });
    // Clear fields after addition
    _foodNameController.clear();
    _priceController.clear();
    _qtyController.clear();
    _descriptionController.clear();
  }

  // Remove a food item from the local list
  void _deleteFoodItem(Food food) {
    setState(() {
      foodItems.removeWhere((f) =>
          f.foodDisplayName == food.foodDisplayName && f.itemID == food.itemID);
    });
  }

  // Save the menu (push all changes to the database)
  void _saveMenu() async {
    if (_menuNameController.text.isEmpty) return;

    // Create or update the menu object locally.
    Menu menuToSave;
    if (widget.menu == null) {
      // Create a new menu.
      menuToSave = Menu(
        id: ID.unique(),
        cafeID: widget.cafe.id,
        name: _menuNameController.text.trim(),
        foodItems: foodItems,
      );
      errorMessage =
          await Appwriteservice().addMenusToCafe(menuToSave, widget.cafe);
      if (errorMessage == null) {
        setState(() {
          widget.cafe.menus.add(menuToSave);
        });
      }
    } else {
      // Update the existing menu.
      widget.menu!.name = _menuNameController.text.trim();
      widget.menu!.foodItems = foodItems;
      errorMessage = await Appwriteservice()
          .updateMenuInDatabase(widget.menu!, widget.cafe);
      // Optionally update widget.cafe.menus locally if needed.
      if (errorMessage == null) {
        // Replace the menu in the cafe's list with the updated version.
        int index =
            widget.cafe.menus.indexWhere((m) => m.id == widget.menu!.id);
        if (index != -1) {
          setState(() {
            widget.cafe.menus[index] = widget.menu!;
          });
        }
      }
    }
    // After saving, pop the screen.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.menu != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Menu" : "Add Menu"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _menuNameController,
              decoration:
                  const InputDecoration(labelText: 'Menu Category Name'),
            ),
            const SizedBox(height: 16),
            const Text(
              "Add Food Item",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addFoodItem,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Add Food"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Food Items",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final food = foodItems[index];
                return ListTile(
                  title: Text(food.foodDisplayName),
                  subtitle: Text(
                      "Price: \$${food.price.toStringAsFixed(2)} | Qty: ${food.qty}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFoodItem(food),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveMenu,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                child: const Text("Save Menu"),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            ]
          ],
        ),
      ),
    );
  }
}
