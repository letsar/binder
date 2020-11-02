import 'package:binder/binder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_todos/data/entities/todo.dart';
import 'package:firestore_todos/data/sources/refs.dart';

final todosRepositoryRef = LogicRef((scope) => TodosRepository(scope));

class TodosRepository with Logic {
  TodosRepository(this.scope);

  @override
  final Scope scope;

  CollectionReference get _collection => read(todoCollectionRef);

  Future<void> addNewTodo(Todo todo) {
    return _collection.add(todo.toDocument());
  }

  Future<void> deleteTodo(Todo todo) async {
    return _collection.doc(todo.id).delete();
  }

  Stream<List<Todo>> todos() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Todo.fromSnapshot(doc)).toList();
    });
  }

  Future<void> updateTodo(Todo update) {
    return _collection.doc(update.id).update(update.toDocument());
  }
}
