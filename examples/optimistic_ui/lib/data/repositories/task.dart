import 'package:binder/binder.dart';
import 'package:optimistic_ui/data/entities/task.dart';
import 'package:optimistic_ui/data/sources/api_client.dart';

final taskRepositoryRef = LogicRef((scope) => TaskRepository(scope));

class TaskRepository with Logic {
  const TaskRepository(this.scope);

  @override
  final Scope scope;

  ApiClient get _apiClient => use(apiClientRef);

  Future<bool> add(Task task) => _apiClient.addTask(task);

  Future<bool> delete(Task task) => _apiClient.deleteTask(task);
}
