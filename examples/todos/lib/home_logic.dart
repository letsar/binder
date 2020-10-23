import 'package:binder/binder.dart';
import 'package:meta/meta.dart';

import 'entities/todo.dart';

final todoListRef = StateRef(const <Todo>[]);
final todoListFilterRef = StateRef(TodoListFilter.all);
final homeLogicRef = LogicRef((scope) => HomeLogic(scope));

class HomeLogic with Logic {
  const HomeLogic(this.scope);

  @override
  final Scope scope;

  TodoListFilter get filter => read(todoListFilterRef);
  set filter(TodoListFilter value) => write(todoListFilterRef, value);

  void init() {
    write(todoListRef, [
      Todo(id: 'todo-0', description: 'hello'),
      Todo(id: 'todo-1', description: 'hola'),
      Todo(id: 'todo-2', description: 'bonjour'),
    ]);
  }

  void add(String description) {
    _updateTodos(
      (list) => [
        ...list,
        Todo(description: description),
      ],
    );
  }

  void toggle(String id) {
    _updateTodo(
      id,
      (todo) => Todo(
        id: todo.id,
        description: todo.description,
        completed: !todo.completed,
      ),
    );
  }

  void edit({@required String id, @required String description}) {
    _updateTodo(
      id,
      (todo) => Todo(
        id: todo.id,
        description: description,
        completed: todo.completed,
      ),
    );
  }

  void remove(String id) {
    _updateTodos(
      (list) => [
        for (final Todo todo in list)
          if (todo.id != id) todo,
      ],
    );
  }

  void _updateTodos(List<Todo> Function(List<Todo>) updater) {
    update(todoListRef, updater);
  }

  void _updateTodo(String id, Todo Function(Todo) updater) {
    _updateTodos(
      (List<Todo> list) => [
        for (final Todo todo in list)
          if (todo.id == id) updater(todo) else todo,
      ],
    );
  }
}
