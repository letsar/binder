import 'package:architecture/core/logics/busy.dart';
import 'package:architecture/data/entities/user.dart';
import 'package:architecture/data/repositories/user.dart';
import 'package:binder/binder.dart';

final homeViewLogicRef = LogicRef((scope) => HomeViewLogic(scope));

final usersRef = StateRef(const <User>[]);

class HomeViewLogic with Logic, BusyLogic implements Loadable {
  const HomeViewLogic(this.scope);

  @override
  final Scope scope;

  UserRepository get _userRepository => use(userRepositoryRef);

  @override
  Future<void> load() async {
    busy = true;
    final users = await _userRepository.getUsers();
    write(usersRef, users);
    busy = false;
  }
}
