import 'package:binder/binder.dart';
import 'package:firestore_todos/modules/add_edit/view.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({
    Key key,
    @required this.id,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    final todo = context.watch(todosRef.select(
      (todos) => todos.firstWhere((todo) => todo.id == id, orElse: () => null),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            tooltip: 'Delete Todo',
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.use(todosLogicRef).delete(todo);
              Navigator.pop(context, todo);
            },
          )
        ],
      ),
      body: todo == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: todo.complete,
                        onChanged: (complete) {
                          context
                              .use(todosLogicRef)
                              .edit(todo.copyWith(complete: complete));
                        },
                      ),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: '${todo.id}__heroTag',
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 16,
                                ),
                                child: Text(
                                  todo.task,
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              ),
                            ),
                            Text(
                              todo.note,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Edit Todo',
        onPressed: todo == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return AddEditView(
                        isEditing: true,
                        todo: todo,
                      );
                    },
                  ),
                );
              },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
