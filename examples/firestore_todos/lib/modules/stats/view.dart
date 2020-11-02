import 'package:binder/binder.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StatsView extends StatelessWidget {
  const StatsView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numActive = context.watch(
      todosRef.select((todos) => todos.where((todo) => !todo.complete).length),
    );
    final numCompleted = context.watch(
      todosRef.select((todos) => todos.where((todo) => todo.complete).length),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Completed Todos',
            style: Theme.of(context).textTheme.headline6,
          ),
          const Gap(8),
          Text(
            '$numCompleted',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const Gap(24),
          Text(
            'Active Todos',
            style: Theme.of(context).textTheme.headline6,
          ),
          const Gap(8),
          Text(
            '$numActive',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
