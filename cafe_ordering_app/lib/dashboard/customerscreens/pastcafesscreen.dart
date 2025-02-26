// pastCafesScreen.dart
import 'package:cafe_ordering_app/dashboard/customerscreens/orderingScreen.dart';

import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';

class PastCafesScreen extends StatelessWidget {
  final List<Cafe> cafes;
  const PastCafesScreen({Key? key, required this.cafes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Cafes'),
        backgroundColor: Colors.pink,
      ),
      body: cafes.isEmpty
          ? const Center(child: Text('No past cafes found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cafes.length,
              itemBuilder: (context, index) {
                final cafe = cafes[index];
                return Card(
                  child: ListTile(
                    title: Text(cafe.name),
                    subtitle: Text(cafe.address),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Optionally, navigate to a detailed cafe info screen.
                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>OrderingScreen(cafe: cafe)));
                    },
                  ),
                );
              },
            ),
    );
  }
}
