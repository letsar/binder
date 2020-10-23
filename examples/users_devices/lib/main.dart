import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:users_devices/modules/assignment/page.dart';

import 'modules/assignment/page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BinderScope(
      // observers: const [DelegatingObserver(_logAction)],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AssignmentPage(),
      ),
    );
  }
}
