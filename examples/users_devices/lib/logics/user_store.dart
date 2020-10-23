import 'package:binder/binder.dart';

import '../data/sources/fake_api_client.dart';
import '../models/user.dart';
import 'store.dart';

final userMapRef = StateRef(const <int, User>{});
final userStoreRef = LogicRef((scope) => UserStore(scope));

class UserStore extends Store<User> {
  UserStore(this.scope) : super(userMapRef);

  @override
  final Scope scope;

  FakeApiClient get _apiClient => use(apiClientRef);

  @override
  Future<Iterable<User>> fetch() {
    return _apiClient.getUsers();
  }
}
