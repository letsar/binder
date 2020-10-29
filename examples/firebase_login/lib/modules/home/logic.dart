import 'package:binder/binder.dart';
import 'package:firebase_login/data/repositories/authentication.dart';

final homeViewLogicRef = LogicRef((scope) => HomeViewLogic(scope));

class HomeViewLogic with Logic {
  const HomeViewLogic(this.scope);

  @override
  final Scope scope;

  AuthenticationRepository get _authenticationRepository =>
      use(authenticationRepositoryRef);

  Future<void> signOut() {
    return _authenticationRepository.signOut();
  }
}
