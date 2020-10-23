import 'package:architecture/refs.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

class UserView extends StatelessWidget {
  const UserView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppBarTitle()),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = context.watch(currentUserRef.select((user) => user.name));
    return Text(name);
  }
}
