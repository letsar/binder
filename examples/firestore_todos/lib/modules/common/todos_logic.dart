import 'dart:async';

import 'package:binder/binder.dart';
import 'package:firestore_todos/data/entities/todo.dart';
import 'package:firestore_todos/data/repositories/todos.dart';

final todosLogicRef = LogicRef((scope) => TodosLogic(scope));

final todosRef = StateRef(const <Todo>[]);

class TodosLogic with Logic implements Disposable {
  TodosLogic(this.scope);

  @override
  final Scope scope;

  TodosRepository get _todosRepository => use(todosRepositoryRef);

  StreamSubscription<List<Todo>> _todosSubscription;

  void init() {
    _todosSubscription?.cancel();
    _todosSubscription = _todosRepository.todos().listen((todos) {
      write(todosRef, todos);
    });
  }

  Future<void> add(Todo todo) {
    return _todosRepository.addNewTodo(todo);
  }

  Future<void> delete(Todo todo) {
    return _todosRepository.deleteTodo(todo);
  }

  Future<void> edit(Todo todo) {
    return _todosRepository.updateTodo(todo);
  }

  @override
  void dispose() {
    _todosSubscription?.cancel();
  }
}
