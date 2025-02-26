import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:cafe_ordering_app/main.dart';
import 'package:cafe_ordering_app/models/requiredModels.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Appwriteservice {
  // Client, session and user info
  static var localClient = Client();
  static Session? userSession;
  static User? userInfo;

  // Database instance and IDs for collections.
  static Databases? databaseinstance;
  static const String databaseID = "67bda55d00259a124f49";
  static const String userTB_Id = "67bda6d5001f4557ac86";
  static const String menusTB = "67beb5640027e2c73fcf";
  static const String cafeTB_id = "67bea77700093f9c3400";

  // Initialize the Appwrite client.
  static void initCleint() {
    localClient
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject("67bd51fb0020fddcd78b")
        .setSelfSigned(status: false);
    databaseinstance = Databases(localClient);
  }

  Future<String?> setUserRole(String role) async {
    try {
      Account account = Account(Appwriteservice.localClient);
      // Update the user's preferences with the new role.
      await account.updatePrefs(prefs: {
        "role": role, // e.g., "customer" or "owner"
      });
      return null; // Success
    } on AppwriteException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> getUserRole() async {
    try {
      Account account = Account(Appwriteservice.localClient);
      // Retrieve the user info from Appwrite.
      final user = await account.get();
      // The updated preferences (including the "role") should be present in the user.prefs property.
      final prefs = user.prefs
          .data; // This is a Map<String, dynamic> containing custom preferences.
      if (prefs.isNotEmpty && prefs.containsKey("role")) {
        return prefs["role"] as String?;
      }
      return null; // Role not set.
    } on AppwriteException catch (e) {
      return e.message;
    }
  }

  Future<String> getUserID() async {
    try {
      Account account = Account(Appwriteservice.localClient);
      // Retrieve the user info from Appwrite.
      final user = await account.get();
      return user.$id;
    } on AppwriteException catch (e) {
      return e.message!;
    }
  }

  static Future<String?> singUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email and Password Cannot be Empty";
    }
    if (password.length < 7 || password.length > 256) {
      return "Password should be between 8-256 Characters";
    }
    Account account = Account(localClient);
    try {
      userInfo = await account.create(
          userId: ID.unique(), email: email, password: password);
      return null;
    } on AppwriteException catch (e) {
      return e.message;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  static Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email and Password Cannot be Empty";
    }
    if (password.length < 7 || password.length > 256) {
      return "Password should be between 8-256 Characters";
    }
    Account account = Account(localClient);
    try {
      userSession = await account.createEmailPasswordSession(
          email: email.trim(), password: password.trim());

      return null;
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        await account.deleteSession(sessionId: 'current');
      }
      return e.message;
    } on Exception catch (E) {
      return E.toString();
    }
  }

  Future<List<Cafe>> fetchAllCafes() async {
    try {
      var listofdocs = await databaseinstance!
          .listDocuments(databaseId: databaseID, collectionId: cafeTB_id);
      return listofdocs.documents.map((x) => Cafe.fromMap(x.data)).toList();
    } on AppwriteException catch (e) {
      showErrorDialog(e.message ?? "Unknown Error");
      return [];
    }
  }

  Future<Cafe?> fetchCafeById(String id) async {
    try {
      var listofdocs = await databaseinstance!.listDocuments(
          databaseId: databaseID,
          collectionId: cafeTB_id,
          queries: [Query.equal('id', id)]);
      return Cafe.fromMap(listofdocs.documents.first.data);
    } on AppwriteException catch (e) {
      showErrorDialog(e.message ?? "Unknown Error");
      return null;
    }
  }

  Future<String?> addCafeToDatabase(Cafe cafe) async {
    try {
      // Check if a cafe with the same name already exists.
      var documentlist = await databaseinstance!.listDocuments(
          databaseId: databaseID,
          collectionId: cafeTB_id,
          queries: [Query.equal('name', cafe.name)]);
      if (documentlist.documents.isNotEmpty) {
        return "Cafe Name already taken.";
      }
      // Create a new cafe document. Note: 'id' is managed by Appwrite.
      var local = await databaseinstance!.createDocument(
          permissions: [
            Permission.read(Role.any()),
            Permission.write(Role.any()),
          ],
          databaseId: databaseID,
          collectionId: cafeTB_id,
          documentId: ID.unique(),
          data: cafe.toMap());
      if (local.data.isNotEmpty) {
        return null;
      } else {
        return 'Data Not Uploaded';
      }
    } on AppwriteException catch (e) {
      return e.message;
    }
  }

  // ----------------------
  // Menu Functions
  // ----------------------

  Future<String?> addMenusToCafe(Menu menu, Cafe cafe) async {
    try {
      // Check if a menu with the same name exists for this cafe.
      var documentlist = await databaseinstance!.listDocuments(
        databaseId: databaseID,
        collectionId: menusTB,
        queries: [
          Query.and([
            Query.equal('name', menu.name),
            Query.equal('cafeID', cafe.id),
          ]),
        ],
      );
      if (documentlist.documents.isNotEmpty) {
        showErrorDialog("Menu name already taken");
        return "Menu Name already taken.";
      }
      // Fetch the corresponding cafe document.
      var cafelist = await databaseinstance!.listDocuments(
        databaseId: databaseID,
        collectionId: cafeTB_id,
        queries: [Query.equal('name', cafe.name)],
      );
      // Insert the new menu into the menus collection.
      await databaseinstance!.createDocument(
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
        databaseId: databaseID,
        collectionId: menusTB,
        documentId: ID.unique(),
        data: menu.toMap(),
      );
      if (cafelist.documents.isNotEmpty) {
        // Insert the menu into the list of menus in the Cafe document.
        cafe.menus.add(menu);
        await databaseinstance!.updateDocument(
          databaseId: databaseID,
          collectionId: cafeTB_id,
          documentId: cafelist.documents.first.$id,
          data: {
            // JSON-encode the menus list.
            'menus': jsonEncode(cafe.menus.map((m) => m.toMap()).toList()),
          },
        );
        return null;
      } else {
        showErrorDialog("Data Not Uploaded");
        return 'Data Not Uploaded';
      }
    } on AppwriteException catch (e) {
      showErrorDialog(e.message!);
      return e.message;
    }
  }

  // Update an existing menu.
  Future<String?> updateMenuInDatabase(Menu menu, Cafe cafe) async {
    try {
      var menudoc = await databaseinstance!.listDocuments(
          databaseId: databaseID,
          collectionId: menusTB,
          queries: [
            Query.or(
                [Query.equal('name', menu.name), Query.equal('id', menu.id)])
          ]).then((onValue) => onValue.documents.first);
      // 1. Update the Menu document in the menus collection.
      await databaseinstance!.updateDocument(
        databaseId: databaseID,
        collectionId: menusTB,
        documentId:
            menudoc.$id, // Ensure menu.id matches the Appwrite document ID.
        data: menu.toMap(),
      );

      // 2. Retrieve the Cafe document that contains the embedded menus.
      var cafeDocs = await databaseinstance!.listDocuments(
        databaseId: databaseID,
        collectionId: cafeTB_id,
        queries: [Query.equal('id', menu.cafeID)],
      );
      if (cafeDocs.documents.isNotEmpty) {
        var cafeDoc = cafeDocs.documents.first;
        var cafeModel = Cafe.fromMap(cafeDoc.data);
        // 3. Replace the old menu with the updated one.
        cafeModel.menus = cafeModel.menus.map((m) {
          if (m.id == menu.id) {
            return menu;
          }
          return m;
        }).toList();
        // 4. Update the Cafe document with the new menus list.
        await databaseinstance!.updateDocument(
          databaseId: databaseID,
          collectionId: cafeTB_id,
          documentId: cafeDoc.$id,
          data: {
            'menus': jsonEncode(cafeModel.menus.map((m) => m.toMap()).toList()),
          },
        );
      }
      return null;
    } on AppwriteException catch (e) {
      showErrorDialog(e.message ?? "Unknown error");
      return e.message;
    }
  }

  static void logout(BuildContext context) async {
    try {
      Account account = Account(Appwriteservice.localClient);
      await account.deleteSession(sessionId: 'current');
      Navigator.pushReplacementNamed(context, '/login');
      return null; // Logout successful.
    } on AppwriteException catch (e) {
      return;
    }
  }

  Future<bool> checkLogin() async {
    try {
      var user = await Account(Appwriteservice.localClient).get();
      // ignore: unnecessary_null_comparison
      if (user == null) {
        return false;
      } else {
        return user.status;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      return false;
      // TODO
    }
  }
  // ----------------------
  // Food Functions
  // ----------------------

  Future<String?> addFoodToMenu(Food food, Menu menu) async {
    try {
      // 1. Retrieve the Menu document by its name.
      var menuDoc = await databaseinstance!.listDocuments(
        databaseId: databaseID,
        collectionId: menusTB,
        queries: [Query.equal('name', menu.name)],
      ).then((value) => value.documents.first);

      // 2. Convert document data to a Menu model and add the new food item.
      var updatedMenu = Menu.fromMap(menuDoc.data);
      updatedMenu.foodItems.add(food);

      // 3. Update the Menu document in the menus collection.
      await databaseinstance!.updateDocument(
        databaseId: databaseID,
        collectionId: menusTB,
        documentId: menuDoc.$id,
        data: updatedMenu.toMap(),
      );

      // 4. Retrieve the corresponding Cafe document.
      // Use 'id' (the actual attribute in Cafe) instead of 'cafeID'.
      var cafeDocResult = await databaseinstance!.listDocuments(
        databaseId: databaseID,
        collectionId: cafeTB_id,
        queries: [Query.equal('id', menu.cafeID)],
      );
      var cafeDoc = cafeDocResult.documents.first;
      var cafeModel = Cafe.fromMap(cafeDoc.data);

      // 5. Update the menus list in the Cafe model.
      cafeModel.menus = cafeModel.menus.map((m) {
        if (m.name == menu.name) {
          m.foodItems.add(food);
        }
        return m;
      }).toList();

      // 6. Update the Cafe document in the cafes collection.
      await databaseinstance!.updateDocument(
        databaseId: databaseID,
        collectionId: cafeTB_id,
        documentId: cafeDoc.$id,
        data: {
          // JSON-encode the menus list.
          'menus': jsonEncode(cafeModel.menus.map((m) => m.toMap()).toList()),
        },
      );

      return null;
    } on Exception catch (e) {
      showErrorDialog(e.toString());
      return e.toString();
    }
  }

  Future<void> deleteFood(Menu menu, Food food) async {
    // 1. Retrieve the Menu document by querying with the menu name.
    var menuDoc = await databaseinstance!.listDocuments(
      databaseId: databaseID,
      collectionId: menusTB,
      queries: [Query.equal('name', menu.name)],
    ).then((value) => value.documents.first);

    // 2. Convert document data to a Menu model.
    var updatedMenu = Menu.fromMap(menuDoc.data);

    // 3. Remove the specified food item.
    updatedMenu.foodItems.removeWhere(
        (element) => element.foodDisplayName == food.foodDisplayName);

    // 4. Update the Menu document.
    await databaseinstance!.updateDocument(
      databaseId: databaseID,
      collectionId: menusTB,
      documentId: menuDoc.$id,
      data: updatedMenu.toMap(),
    );

    // 5. Retrieve the corresponding Cafe document.
    var cafeDocResult = await databaseinstance!.listDocuments(
      databaseId: databaseID,
      collectionId: cafeTB_id,
      queries: [Query.equal('cafeID', menu.cafeID)],
    );
    var cafeDoc = cafeDocResult.documents.first;
    var cafeModel = Cafe.fromMap(cafeDoc.data);

    // 6. Update the embedded menus in the Cafe document.
    cafeModel.menus = cafeModel.menus.map((m) {
      if (m.name == menu.name) {
        m.foodItems.removeWhere(
            (element) => element.foodDisplayName == food.foodDisplayName);
      }
      return m;
    }).toList();

    // 7. Update the Cafe document.
    await databaseinstance!.updateDocument(
      databaseId: databaseID,
      collectionId: cafeTB_id,
      documentId: cafeDoc.$id,
      data: {
        'menus': jsonEncode(cafeModel.menus.map((m) => m.toMap()).toList()),
      },
    );
  }

  // Helper function to show errors using a global navigator key.
  void showErrorDialog(String message) {
    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void showErrorDialogWContext(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  /// Fetch all orders placed by the given userID by iterating over all cafes.
  Future<List<Order>> fetchAllOrdersByUserID(String userID) async {
    List<Order> userOrders = [];
    try {
      // Fetch all cafes
      List<Cafe> cafes = await fetchAllCafes();
      for (var cafe in cafes) {
        for (var order in cafe.orders) {
          if (order.userid == userID) {
            userOrders.add(order);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }
    return userOrders;
  }

  Future<String?> placeOrder(Order order, Cafe cafe) async {
    try {
      var cafeDocs = await Appwriteservice.databaseinstance!.listDocuments(
        databaseId: Appwriteservice.databaseID,
        collectionId: Appwriteservice.cafeTB_id,
        queries: [Query.equal('id', cafe.id)],
      );
      if (cafeDocs.documents.isEmpty) {
        return "Cafe not found.";
      }

      var cafeDoc = cafeDocs.documents.first;
      Cafe cafeModel = Cafe.fromMap(cafeDoc.data);

      cafeModel.orders.add(order);

      await Appwriteservice.databaseinstance!.updateDocument(
        databaseId: Appwriteservice.databaseID,
        collectionId: Appwriteservice.cafeTB_id,
        documentId: cafeDoc.$id,
        data: {
          'orders': jsonEncode(cafeModel.orders.map((o) => o.toMap()).toList()),
        },
      );
      return null;
    } on AppwriteException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Fetch all cafes.
      List<Cafe> cafes = await Appwriteservice().fetchAllCafes();
      for (var cafe in cafes) {
        bool orderFound = false;
        for (var order in cafe.orders) {
          if (order.id == orderId) {
            order.status = newStatus;
            orderFound = true;
          }
        }
        if (orderFound) {
          // Fetch the specific Cafe document using its 'id'
          var cafeDocs = await Appwriteservice.databaseinstance!.listDocuments(
            databaseId: Appwriteservice.databaseID,
            collectionId: Appwriteservice.cafeTB_id,
            queries: [Query.equal('id', cafe.id)],
          );
          if (cafeDocs.documents.isNotEmpty) {
            var cafeDoc = cafeDocs.documents.first;
            // Update the Cafe document's orders field.
            await Appwriteservice.databaseinstance!.updateDocument(
              databaseId: Appwriteservice.databaseID,
              collectionId: Appwriteservice.cafeTB_id,
              documentId: cafeDoc.$id,
              data: {
                'orders':
                    jsonEncode(cafe.orders.map((o) => o.toMap()).toList()),
              },
            );
            return null;
          }
        }
      }
      return "Order not found.";
    } on AppwriteException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
