import 'package:architecture/data/entities/user.dart';
import 'package:architecture/data/sources/api_client.dart';
import 'package:binder/binder.dart';

final userRepositoryRef = LogicRef((scope) => UserRepository(scope));

class UserRepository with Logic {
  const UserRepository(this.scope);

  @override
  final Scope scope;

  ApiClient get _apiClient => use(apiClientRef);

  Future<List<User>> getUsers() {
    return _apiClient.getUsers();
  }
}
