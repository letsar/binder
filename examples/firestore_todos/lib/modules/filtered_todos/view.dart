import 'package:binder/binder.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';
import 'package:firestore_todos/modules/filtered_todos/widgets/todo_item.dart';
import 'package:firestore_todos/modules/home/logic.dart';
import 'package:flutter/material.dart';

final filteredTodosRef = Computed((watch) {
  final filter = watch(activeFilterRef);
  return watch(todosRef).where((todo) {
    switch (filter) {
      case VisibilityFilter.active:
        return !todo.complete;
      case VisibilityFilter.completed:
        return todo.complete;
      default:
        return true;
    }
  }).toList();
});

class FilteredTodosView extends StatelessWidget {
  const FilteredTodosView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todos = context.watch(filteredTodosRef);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return BinderScope(
          overrides: [todoItemRef.overrideWith(todos[index])],
          child: const TodoItem(),
        );
      },
    );
  }
}
