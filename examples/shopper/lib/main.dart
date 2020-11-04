import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:shopper/common/theme.dart';
import 'package:shopper/screens/cart.dart';
import 'package:shopper/screens/catalog.dart';
import 'package:shopper/screens/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use BinderScope to store a part of your app state.
    return BinderScope(
      child: MaterialApp(
        title: 'Provider Demo',
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const MyLogin(),
          '/catalog': (context) => const MyCatalog(),
          '/cart': (context) => const MyCart(),
        },
      ),
    );
  }
}
