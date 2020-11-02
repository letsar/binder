import 'package:binder/binder.dart';
import 'package:firestore_todos/data/entities/todo.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';

final addEditViewLogicRef = LogicRef((scope) => AddEditViewLogic(scope));

final taskRef = StateRef('');
final noteRef = StateRef('');

final taskIsValidRef = Computed((watch) {
  final x = watch(taskRef);
  final t = watch(taskRef).trim().isNotEmpty;
  return t;
});

final canBeSubmittedRef = Computed((watch) {
  return watch(taskIsValidRef);
});

class AddEditViewLogic with Logic {
  const AddEditViewLogic(this.scope);

  @override
  final Scope scope;

  TodosLogic get _todosLogic => use(todosLogicRef);

  String get task => read(taskRef);
  set task(String value) => write(taskRef, value);

  String get note => read(noteRef);
  set note(String value) => write(noteRef, value);

  Future<void> put(Todo todo, {bool isEditing}) {
    if (isEditing) {
      return _todosLogic.edit(todo.copyWith(task: task, note: note));
    } else {
      return _todosLogic.add(Todo(task, note: note));
    }
  }
}
