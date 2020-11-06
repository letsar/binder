import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/task.dart';
import 'package:optimistic_ui/data/repositories/task.dart';

final tasksRef = StateRef(const <Task>[]);

final errorRef = StateRef('');

final tasksViewLogicRef = LogicRef((scope) => TasksViewLogic(scope));

class TasksViewLogic with Logic {
  TasksViewLogic(this.scope);

  @override
  final Scope scope;

  int counter = 0;

  TaskRepository get _taskRepository => use(taskRepositoryRef);

  Future<void> add() async {
    final task = Task(
      id: '${++counter}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _add(task);
    final success = await _taskRepository.add(task);
    if (!success) {
      // If there are issues, we remove the task.
      _delete(task);
      write(errorRef, 'The task ${task.id} could not be added.');
    }
  }

  Future<void> delete(Task task) async {
    _delete(task);
    final success = await _taskRepository.delete(task);
    if (!success) {
      _add(task);
      write(errorRef, 'The task ${task.id} could not be deleted.');
    }
  }

  void _add(Task task) {
    write(tasksRef, [...read(tasksRef), task]);
  }

  void _delete(Task task) {
    write(tasksRef, read(tasksRef).toList()..remove(task));
  }
}
