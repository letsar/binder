import 'package:firestore_todos/modules/common/todos_logic.dart';
import 'package:firestore_todos/modules/home/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:binder/binder.dart';

enum ExtraAction { toggleAll, clearCompleted }

class ExtraActions extends StatelessWidget {
  const ExtraActions({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasTodo = context.watch(todosRef.select((todos) => todos.isNotEmpty));

    if (hasTodo) {
      final allComplete = context.watch(
          todosRef.select((todos) => todos.every((todo) => todo.complete)));
      return PopupMenuButton<ExtraAction>(
        onSelected: (action) {
          switch (action) {
            case ExtraAction.clearCompleted:
              context.use(homeViewLogicRef).clearCompleted();
              break;
            case ExtraAction.toggleAll:
              context.use(homeViewLogicRef).toggleAll();
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuItem<ExtraAction>>[
          PopupMenuItem<ExtraAction>(
            value: ExtraAction.toggleAll,
            child:
                Text(allComplete ? 'Mark all incomplete' : 'Mark all complete'),
          ),
          const PopupMenuItem<ExtraAction>(
            value: ExtraAction.clearCompleted,
            child: Text('Clear completed'),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
