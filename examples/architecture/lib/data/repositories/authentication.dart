import 'package:architecture/data/sources/authentication_api_client.dart';
import 'package:architecture/data/sources/preferences.dart';
import 'package:binder/binder.dart';
import 'package:meta/meta.dart';

final authenticationRepositoryRef =
    LogicRef((scope) => AuthenticationRepository(scope));

class AuthenticationRepository with Logic {
  const AuthenticationRepository(this.scope);

  @override
  final Scope scope;

  AuthenticationApiClient get _authenticationApiClient =>
      use(authenticationApiClientRef);

  Preferences get _preferences => use(preferencesRef);

  Future<bool> autoSignIn() async {
    // We can automatically sign in a user if they choose to be remembered and
    // if the last time they signed in is less than 5 minutes.
    final rememberMe = await _preferences.rememberMe.load();
    final lastSignIn = await _preferences.lastSignIn.load();

    if (rememberMe == true &&
        lastSignIn != null &&
        DateTime.fromMillisecondsSinceEpoch(lastSignIn)
            .isAfter(DateTime.now().subtract(const Duration(minutes: 5)))) {
      // In a real app, we would get a token from secure storage.
      return _authenticationApiClient.signIn('default', 'password');
    } else {
      return false;
    }
  }

  Future<bool> signIn({
    @required String username,
    @required String password,
    @required bool rememberMe,
  }) async {
    await _preferences.rememberMe.save(rememberMe);
    await _preferences.lastSignIn.save(DateTime.now().millisecondsSinceEpoch);
    return _authenticationApiClient.signIn(username, password);
  }

  Future<bool> signOut() async {
    await _preferences.rememberMe.save(false);
    return _authenticationApiClient.signOut();
  }
}
