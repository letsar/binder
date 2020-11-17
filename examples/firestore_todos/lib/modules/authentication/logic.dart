import 'dart:async';

import 'package:binder/binder.dart';
import 'package:firestore_todos/data/repositories/user.dart';
import 'package:firestore_todos/modules/common/todos_logic.dart';

final authenticationViewLogicRef =
    LogicRef((scope) => AuthenticationViewLogic(scope));

final isAuthenticatedRef = StateRef<bool>(null);

class AuthenticationViewLogic with Logic implements Loadable, Disposable {
  AuthenticationViewLogic(this.scope);

  @override
  final Scope scope;

  StreamSubscription<bool> _subscription;

  UserRepository get _userRepository => use(userRepositoryRef);
  TodosLogic get _todosLogic => use(todosLogicRef);

  @override
  Future<void> load() async {
    _subscription?.cancel();
    _subscription = _userRepository.isAuthenticated.listen((isAuthenticated) {
      write(isAuthenticatedRef, isAuthenticated);
    });
    _todosLogic.init();
    _userRepository.authenticate();
  }

  Future<void> authenticate() {
    return _userRepository.authenticate();
  }

  @override
  void dispose() {
    _subscription?.cancel();
  }
}
