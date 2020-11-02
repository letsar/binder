import 'package:binder/binder.dart';
import 'package:firestore_todos/data/entities/todo.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';
import 'package:firestore_todos/modules/details/view.dart';
import 'package:flutter/material.dart';

final todoItemRef = StateRef<Todo>(null);

class TodoItem extends StatelessWidget {
  const TodoItem({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo = context.watch(todoItemRef);
    return Dismissible(
      key: ValueKey('__todo_item_${todo.id}'),
      onDismissed: (_) {
        context.use(todosLogicRef).delete(todo);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(createDeleteTodoSnackBar(context, todo));
      },
      child: ListTile(
        onTap: () async {
          final removedTodo = await Navigator.of(context).push<Todo>(
            MaterialPageRoute(builder: (_) {
              return DetailsView(id: todo.id);
            }),
          );

          if (removedTodo != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(createDeleteTodoSnackBar(context, todo));
          }
        },
        leading: Checkbox(
          value: todo.complete,
          onChanged: (complete) => context
              .use(todosLogicRef)
              .edit(todo.copyWith(complete: complete)),
        ),
        title: Hero(
          tag: '${todo.id}__heroTag',
          child: SizedBox(
            width: double.infinity,
            child: Text(
              todo.task,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        subtitle: todo.note.isNotEmpty
            ? Text(
                todo.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.subtitle1,
              )
            : null,
      ),
    );
  }
}

SnackBar createDeleteTodoSnackBar(BuildContext context, Todo todo) {
  return SnackBar(
    content: Text(
      'Deleted ${todo.task}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () => context.use(todosLogicRef).add(todo),
    ),
  );
}
