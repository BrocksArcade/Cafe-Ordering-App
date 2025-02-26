import 'package:cafe_ordering_app/Auth/LoginRegisterationScreen.dart';
import 'package:cafe_ordering_app/Auth/routingScreen.dart';
import 'package:cafe_ordering_app/Netowkrs/AppwriteService.dart';
import 'package:cafe_ordering_app/dashboard/customerscreens/customerHomeScreen.dart';
import 'package:cafe_ordering_app/dashboard/ownerscreens/managecafescreen.dart';
import 'package:flutter/material.dart';
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Appwriteservice.initCleint();
  var remeberme=await Appwriteservice().checkLogin();
  runApp(MaterialApp(
    navigatorObservers: [routeObserver],
    navigatorKey: navigatorKey,
    initialRoute: remeberme?'/routing':'/login',
    routes: {
      '/customerHome': (context) => const CustomerHomeScreen(),
      '/ownerHome': (context) => const ManageCafeScreen(),
      '/login':(context)=>const LoginScreen(),
      '/routing':(context)=>const RoutingScreen()
    },
  ));
}
