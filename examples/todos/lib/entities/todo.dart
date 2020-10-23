import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

class Todo {
  Todo({
    String id,
    @required this.description,
    this.completed = false,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

enum TodoListFilter {
  all,
  active,
  completed,
}
