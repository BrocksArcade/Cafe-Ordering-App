import 'dart:convert';

class Cafe {
  final String id;
  String name;
  String address;
  String contactNumber;
  String userId; // New attribute
  List<Menu> menus;
  List<Order> orders;

  Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.userId,
    this.menus = const [],
    this.orders = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contactNumber': contactNumber,
      'userId': userId,
      // Encode lists as JSON strings:
      'menus': jsonEncode(menus.map((menu) => menu.toMap()).toList()),
      'orders': jsonEncode(orders.map((order) => order.toMap()).toList()),
    };
  }

  factory Cafe.fromMap(Map<String, dynamic> map) {
    return Cafe(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      contactNumber: map['contactNumber'],
      userId: map['userId'] ?? "",
      // Decode the JSON strings back into lists:
      menus: map['menus'] != null && map['menus'].isNotEmpty
          ? List<Menu>.from(jsonDecode(map['menus']).map((x) => Menu.fromMap(x)))
          : [],
      orders: map['orders'] != null && map['orders'].isNotEmpty
          ? List<Order>.from(jsonDecode(map['orders']).map((x) => Order.fromMap(x)))
          : [],
    );
  }
}

class Menu {
  final String id;
  final String cafeID;
  String name;
  List<Food> foodItems;

  Menu({
    required this.id,
    required this.name,
    required this.cafeID,
    this.foodItems = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cafeID': cafeID,
      // Store foodItems as a JSON string:
      'foodItems': jsonEncode(foodItems.map((food) => food.toMap()).toList()),
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['id'],
      name: map['name'],
      cafeID: map['cafeID'],
      foodItems: map['foodItems'] != null && map['foodItems'].toString().isNotEmpty
          ? List<Food>.from(jsonDecode(map['foodItems']).map((x) => Food.fromMap(x)))
          : [],
    );
  }
}

class Order {
  final String id;
  final String menuID;
  final String userid;
  List<Food> foodItems;
  String status; // Possible values: 'Preparing', 'Dispatched', 'Completed'

  Order({
    required this.id,
    required this.menuID,
    required this.userid,
    this.foodItems = const [],
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuID': menuID,
      'userid': userid,
      // Store foodItems as a JSON string:
      'foodItems': jsonEncode(foodItems.map((food) => food.toMap()).toList()),
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      menuID: map['menuID'],
      userid: map['userid'],
      foodItems: map['foodItems'] != null && map['foodItems'].toString().isNotEmpty
          ? List<Food>.from(jsonDecode(map['foodItems']).map((x) => Food.fromMap(x)))
          : [],
      status: map['status'],
    );
  }
}

class Food {
  final String itemID;
  String foodDisplayName;
  String description;
  double price;
  int qty;

  Food({
    required this.itemID,
    required this.foodDisplayName,
    required this.description,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemID': itemID,
      'foodDisplayName': foodDisplayName,
      'description': description,
      'price': price,
      'qty': qty,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      itemID: map['itemID'],
      foodDisplayName: map['foodDisplayName'],
      description: map['description'],
      price: map['price'] is num ? (map['price'] as num).toDouble() : 0.0,
      qty: map['qty'] ?? 0,
    );
  }
}
