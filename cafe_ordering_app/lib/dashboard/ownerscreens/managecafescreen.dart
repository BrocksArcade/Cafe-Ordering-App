// manage_cafe_screen.dart
import 'package:cafe_ordering_app/Netowkrs/AppwriteService.dart';
import 'package:cafe_ordering_app/dashboard/ownerscreens/cafedetailsscreen.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class ManageCafeScreen extends StatefulWidget {
  const ManageCafeScreen({super.key});

  @override
  _ManageCafeScreenState createState() => _ManageCafeScreenState();
}

class _ManageCafeScreenState extends State<ManageCafeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();

  List<Cafe> cafes = [];

  @override
  void initState() {
    super.initState();
    _fetchCafes();
  }

  Future<void> _fetchCafes() async {
    cafes = await Appwriteservice().fetchAllCafes();
    setState(() {});
  }

  String? errormessage; // Dummy list of cafes

  // Placeholder function to add a new cafe
  void _addCafe() async {
    if (_formKey.currentState!.validate()) {
      final newCafe = Cafe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: "",
        name: _nameController.text,
        address: _addressController.text,
        contactNumber: _contactController.text,
        menus: [],
        orders: [],
      );

      // Push the new cafe to the database.
      String? error = await Appwriteservice().addCafeToDatabase(newCafe);
      if (error == null) {
        // If successful, add it to the local list and clear fields.
        setState(() {
          cafes.add(newCafe);
        });
        _nameController.clear();
        _addressController.clear();
        _contactController.clear();
      } else {
        // Handle error (e.g., show error message)
        setState(() {
          errormessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.pink,
        onPressed: () => Appwriteservice.logout(context),
        child: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: const Text('Manage Cafes'),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Cafe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Cafe Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter cafe name' : null,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter address' : null,
                  ),
                  TextFormField(
                      maxLength: 10,
                      controller: _contactController,
                      decoration:
                          const InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter mobile number';
                        } else if (value.length < 10) {
                          return "Enter 10 Digits";
                        } else {
                          return null;
                        }
                      }),
                  const SizedBox(height: 16),
                  Text(
                    errormessage ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: _addCafe,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text('Add Cafe'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'My Cafes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (cafes.isEmpty) const Text("No Cafes Found"),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cafes.length,
              itemBuilder: (context, index) {
                final cafe = cafes[index];
                return Card(
                  child: ListTile(
                    title: Text(cafe.name),
                    subtitle: Text(cafe.address),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to the cafe details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CafeDetailsScreen(cafe: cafe),
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
    );
  }
}
