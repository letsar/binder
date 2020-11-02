import 'package:binder/binder.dart';
import 'package:firestore_todos/data/entities/todo.dart';
import 'package:firestore_todos/modules/add_edit/logic.dart';
import 'package:flutter/material.dart';

class AddEditView extends StatelessWidget {
  const AddEditView({
    Key key,
    @required this.isEditing,
    this.todo,
  }) : super(key: key);

  final bool isEditing;
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BinderScope(
      overrides: [
        taskRef.overrideWith(todo?.task ?? ''),
        noteRef.overrideWith(todo?.note ?? ''),
        addEditViewLogicRef.overrideWithSelf(),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                isEditing ? 'Edit Todo' : 'Add Todo',
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: isEditing ? todo.task : '',
                    onChanged: (value) =>
                        context.use(addEditViewLogicRef).task = value,
                    autofocus: !isEditing,
                    style: textTheme.headline5,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      errorText: context.watch(taskIsValidRef)
                          ? null
                          : 'Please enter some text',
                    ),
                  ),
                  TextFormField(
                    initialValue: isEditing ? todo.note : '',
                    onChanged: (value) =>
                        context.use(addEditViewLogicRef).note = value,
                    maxLines: 10,
                    style: textTheme.subtitle1,
                    decoration: const InputDecoration(
                      hintText: 'Additional Notes...',
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: isEditing ? 'Save changes' : 'Add Todo',
              onPressed: context.watch(canBeSubmittedRef)
                  ? () {
                      context
                          .use(addEditViewLogicRef)
                          .put(todo, isEditing: isEditing);
                      Navigator.pop(context);
                    }
                  : null,
              child: Icon(isEditing ? Icons.check : Icons.add),
            ),
          );
        },
      ),
    );
  }
}
