import 'package:binder/binder.dart';

import '../../extensions.dart';

final authenticationApiClientRef =
    LogicRef((scope) => AuthenticationApiClient());

class AuthenticationApiClient {
  Future<bool> signIn(String username, String password) {
    return Future.value(password != null &&
            password.length > 3 &&
            username != null &&
            username.isNotEmpty)
        .fakeDelay();
  }

  Future<bool> signOut() {
    return Future.value(true).fakeDelay();
  }
}
