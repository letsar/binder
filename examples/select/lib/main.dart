import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:select/user.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BinderScope(child: MaterialApp(home: UserView()));
  }
}

final userRef = StateRef(const User('Darth', 'Vader', 0));

final userViewLogicRef = LogicRef((scope) => UserViewLogic(scope));

class UserViewLogic with Logic {
  const UserViewLogic(this.scope);

  @override
  final Scope scope;

  void increment() => update(
        userRef,
        (User user) => User(
          user.firstName,
          user.lastName,
          user.score + 1,
        ),
      );
}

class UserView extends StatelessWidget {
  const UserView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppBarTitle()),
      body: const Center(child: ScoreView()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.use(userViewLogicRef).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullName = context.watch(
      userRef.select((user) => '${user.firstName} ${user.lastName}'),
    );
    return Text(fullName);
  }
}

class ScoreView extends StatelessWidget {
  const ScoreView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final score = context.watch(userRef.select((user) => user.score));
    return Text(
      'Score: $score',
      style: Theme.of(context).textTheme.headline1,
      textAlign: TextAlign.center,
    );
  }
}
