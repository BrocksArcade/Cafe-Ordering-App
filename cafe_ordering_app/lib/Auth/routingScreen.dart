import 'package:flutter/material.dart';
import 'package:cafe_ordering_app/Netowkrs/AppwriteService.dart';

class RoutingScreen extends StatefulWidget {
  const RoutingScreen({super.key});

  @override
  _RoutingScreenState createState() => _RoutingScreenState();
}

class _RoutingScreenState extends State<RoutingScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    // Get the stored role (if any) from Appwrite.
    String? role = await Appwriteservice().getUserRole();
    if (role != null && role.isNotEmpty) {
      _navigateBasedOnRole(role);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateBasedOnRole(String role) {
    if (role.toLowerCase() == 'owner') {
      Navigator.pushReplacementNamed(context, '/ownerHome');
    } else if (role.toLowerCase() == 'customer') {
      Navigator.pushReplacementNamed(context, '/customerHome');
    }
  }

  Future<void> _setRoleAndNavigate(String role) async {
    // Set the user role in Appwrite.
    String? error = await Appwriteservice().setUserRole(role);
    if (error == null) {
      _navigateBasedOnRole(role);
    } else {
      // Optionally, show an error message.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking for role.
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // When pressed, set role as 'owner' then navigate.
                _setRoleAndNavigate('owner');
              },
              icon: const Icon(Icons.store),
              label: const Text(
                'Are you Cafe Owner?',
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // When pressed, set role as 'customer' then navigate.
                _setRoleAndNavigate('customer');
              },
              icon: const Icon(Icons.person),
              label: const Text(
                'Are You Cafe Customer?',
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
