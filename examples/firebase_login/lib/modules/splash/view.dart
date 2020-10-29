import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    Key key,
  }) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 150,
        ),
      ),
    );
  }
}
