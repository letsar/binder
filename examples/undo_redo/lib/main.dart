import 'package:flutter/material.dart';
import 'package:binder/binder.dart';

void main() {
  runApp(const MyApp());
}

final intRef = StateRef(0);
final colorRef = StateRef(Colors.blue);

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MementoScope(
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: context.watch(colorRef),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const MyHomePage(),
        );
      }),
    );
  }
}

final myHomePageLogicRef = LogicRef((scope) => MyHomePageLogic(scope));

class MyHomePageLogic with Logic {
  const MyHomePageLogic(this.scope);

  @override
  final Scope scope;

  void increment() => update(intRef, (int x) => x + 1, 'increment');
  void setColor(MaterialColor color) => write(colorRef, color, 'skin');
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int counter = context.watch(intRef);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                _ColorChanger(color: Colors.blue),
                _ColorChanger(color: Colors.red),
                _ColorChanger(color: Colors.green),
              ],
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4),
            child: FloatingActionButton(
              onPressed: () => context.use(myHomePageLogicRef).increment(),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: FloatingActionButton(
              onPressed: () => context.use(myHomePageLogicRef).undo(),
              tooltip: 'Undo',
              child: const Icon(Icons.undo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: FloatingActionButton(
              onPressed: () => context.use(myHomePageLogicRef).redo(),
              tooltip: 'Redo',
              child: const Icon(Icons.redo),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChanger extends StatelessWidget {
  const _ColorChanger({
    Key key,
    this.color,
  }) : super(key: key);

  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.use(myHomePageLogicRef).setColor(color),
      child: Container(
        color: color,
        margin: const EdgeInsets.all(8),
        height: 50,
        width: 50,
      ),
    );
  }
}

extension LogStringExtensions<T> on T {
  String toLog() {
    final T value = this;
    if (value is MaterialColor) {
      return 'Color(0x${value.value.toRadixString(16).padLeft(8, '0')})';
    } else {
      return toString();
    }
  }
}
