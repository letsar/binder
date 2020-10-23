import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// The [BinderScope] widget is where the app state is stored.
    return const BinderScope(child: MaterialApp(home: CounterView()));
  }
}

/// A [StateRef] declares a part of the global app state with its initial state.
final counterRef = StateRef(0);

/// A [LogicRef] declares a business logic component, which is able to mutate
/// the app state.
final counterViewLogicRef = LogicRef((scope) => CounterViewLogic(scope));

/// A business logic component can apply the [Logic] mixin to have access to
/// useful methods, such as `write` and `read`.
class CounterViewLogic with Logic {
  const CounterViewLogic(this.scope);

  /// This is the object which is able to interact with other components.
  @override
  final Scope scope;

  /// We can use the [write] method to mutate the state referenced by a
  /// [StateRef] and [read] to obtain its current state.
  void increment() => write(counterRef, read(counterRef) + 1);
}

class CounterView extends StatelessWidget {
  const CounterView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// We call the [watch] extension method on a [StateRef] to rebuild the
    /// widget when the underlaying state changes.
    final counter = context.watch(counterRef);

    return Scaffold(
      appBar: AppBar(title: const Text('Binder example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$counter', style: Theme.of(context).textTheme.headline4),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        /// We call the [use] extension method to get a business logic component
        /// and call the appropriate method.
        onPressed: () => context.use(counterViewLogicRef).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
