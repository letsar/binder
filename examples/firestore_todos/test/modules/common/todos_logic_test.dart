import 'dart:async';

import 'package:binder/binder.dart';
import 'package:firestore_todos/data/entities/todo.dart';
import 'package:firestore_todos/data/repositories/todos.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class MockScope extends Mock implements Scope {}

final mockTodosRepository = MockTodosRepository();

void main() {
  setUp(() {
    reset(mockTodosRepository);
  });

  test(
      'Verify that todosRef is updated when a new value is added to the repository stream',
      () {
    final scope = MockScope();
    when(scope.use(todosRepositoryRef)).thenReturn(mockTodosRepository);

    final streamController = StreamController<List<Todo>>(sync: true);
    final stream = streamController.stream.asBroadcastStream();
    when(mockTodosRepository.todos()).thenAnswer((_) => stream);

    List<Todo> todos;
    final logic = TodosLogic(scope);

    logic.init();
    verifyNever(scope.write(todosRef, any));

    todos = <Todo>[];
    streamController.add(todos);
    verify(scope.write(todosRef, todos));

    todos = <Todo>[null];
    streamController.add(todos);
    verify(scope.write(todosRef, todos));

    todos = const <Todo>[Todo('my task')];
    streamController.add(todos);
    verify(scope.write(todosRef, todos));
  });
}
