import 'package:architecture/core/logics/busy.dart';
import 'package:architecture/data/repositories/authentication.dart';
import 'package:binder/binder.dart';

final authenticationViewLogicRef =
    LogicRef((scope) => AuthenticationViewLogic(scope));

final usernameRef = StateRef('');
final passwordRef = StateRef('');
final rememberMeRef = StateRef(false);

class AuthenticationViewLogic with Logic, BusyLogic {
  const AuthenticationViewLogic(this.scope);

  @override
  final Scope scope;

  AuthenticationRepository get _authenticationRepository =>
      use(authenticationRepositoryRef);

  String get username => read(usernameRef);
  set username(String value) => write(usernameRef, value);

  String get password => read(passwordRef);
  set password(String value) => write(passwordRef, value);

  bool get rememberMe => read(rememberMeRef);
  set rememberMe(bool value) => write(rememberMeRef, value);

  Future<void> signIn() async {
    busy = true;
    final isAuthenticationSuccessful = await _authenticationRepository.signIn(
      username: username,
      password: password,
      rememberMe: rememberMe,
    );

    final authenticationResult = isAuthenticationSuccessful
        ? AuthenticationSuccess()
        : AuthenticationFailure();

    write(authenticationResultRef, authenticationResult);

    busy = false;
  }
}

final authenticationResultRef = StateRef<AuthenticationResult>(null);

class AuthenticationResult {}

class AuthenticationSuccess extends AuthenticationResult {}

class AuthenticationFailure extends AuthenticationResult {}
