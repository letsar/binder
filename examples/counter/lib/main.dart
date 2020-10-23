import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

final counterRef = StateRef(0);
final homeLogicRef = LogicRef((scope) => HomeLogic(scope));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counter = context.watch(counterRef);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binder Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.use(homeLogicRef).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeLogic with Logic {
  HomeLogic(this.scope);

  @override
  final Scope scope;

  void increment() {
    update(counterRef, (int x) => x + 1);
  }
}
