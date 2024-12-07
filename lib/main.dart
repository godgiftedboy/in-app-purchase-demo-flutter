import 'dart:developer' as dev;
import 'package:demo_purchase/app.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool test = await InAppPurchase.instance.isAvailable();

  dev.log("Hello here $test");

  runApp(
    MyApp(
      navKey: navKey,
    ),
  );
}
