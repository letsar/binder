import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BinderScope(child: MaterialApp(home: HomeView()));
  }
}

final countersRef = StateRef(const <int>[]);
final indexRef = StateRef(0);

class HomeView extends StatelessWidget {
  const HomeView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final countersCount =
        context.watch(countersRef.select((counters) => counters.length));

    return Scaffold(
      appBar: AppBar(title: const Text('Counters')),
      body: Column(
        children: [
          const SumView(),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              children: [
                for (int i = 0; i < countersCount; i++)
                  BinderScope(
                    overrides: [indexRef.overrideWith(i)],
                    child: const CounterView(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final countersLogic = LogicRef((scope) => CountersLogic(scope));

class CountersLogic with Logic {
  const CountersLogic(this.scope);

  @override
  final Scope scope;

  void addCounter() {
    write(countersRef, read(countersRef).toList()..add(0));
  }

  void increment(int index) {
    final counters = read(countersRef).toList();
    counters[index]++;
    write(countersRef, counters);
  }
}

class SumView extends StatelessWidget {
  const SumView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sum = context.watch(countersRef.select(
      (counters) => counters.fold<int>(0, (a, b) => a + b),
    ));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'sum: $sum',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.use(countersLogic).addCounter(),
            child: const Text('Add counter'),
          ),
        ],
      ),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final index = context.watch(indexRef);
    final counter =
        context.watch(countersRef.select((counters) => counters[index]));

    return Card(
      child: InkResponse(
        onTap: () => context.use(countersLogic).increment(index),
        child: Center(
          child: Text(
            '$counter',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ),
    );
  }
}
