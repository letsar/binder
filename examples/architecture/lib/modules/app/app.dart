import 'package:architecture/modules/app/route_names.dart' as route_names;
import 'package:architecture/modules/authentication/view.dart';
import 'package:architecture/modules/home/view.dart';
import 'package:architecture/modules/splash/view.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    Key key,
    this.mockHome,
  }) : super(key: key);

  final Widget mockHome;

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      child: MaterialApp(
        title: 'Binder Architecture',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          route_names.splash: (_) => mockHome ?? const SplashView(),
          route_names.home: (_) => const HomeView(),
          route_names.authentication: (_) => const AuthenticationView(),
        },
      ),
    );
  }
}
