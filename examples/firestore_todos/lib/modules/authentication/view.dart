import 'package:firestore_todos/modules/authentication/logic.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

class AuthenticationView extends StatelessWidget {
  const AuthenticationView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
      ),
      body: LogicLoader(
        refs: [authenticationViewLogicRef],
        child: StateListener<bool>(
          watchable: isAuthenticatedRef,
          onStateChanged: (BuildContext context, bool isAuthenticated) {
            if (isAuthenticated) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          child: const AuthenticationBody(),
        ),
      ),
    );
  }
}

class AuthenticationBody extends StatelessWidget {
  const AuthenticationBody({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch(isAuthenticatedRef);
    if (isAuthenticated == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return const Center(
        child: Text('Could not authenticate with Firestore'),
      );
    }
  }
}
