import 'dart:async';

import 'package:binder/binder.dart';
import 'package:firebase_login/data/entities/user.dart';
import 'package:firebase_login/data/repositories/authentication.dart';

final authenticationLogicRef = LogicRef((scope) => AuthenticationLogic(scope));

final currentUserRef = StateRef<User>(null);

class AuthenticationLogic with Logic implements Disposable {
  AuthenticationLogic(this.scope);

  @override
  final Scope scope;

  AuthenticationRepository get _authenticationRepository =>
      use(authenticationRepositoryRef);

  StreamSubscription<User> _userSubscription;

  void init() {
    _userSubscription = _authenticationRepository.user.listen((user) {
      write(currentUserRef, user);
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
  }
}
