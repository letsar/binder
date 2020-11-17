import 'package:architecture/data/repositories/authentication.dart';
import 'package:binder/binder.dart';

final splashViewLogicRef = LogicRef((scope) => SplashViewLogic(scope));

class SplashViewLogic with Logic implements Loadable {
  const SplashViewLogic(this.scope);

  @override
  final Scope scope;

  AuthenticationRepository get _authenticationRepository =>
      use(authenticationRepositoryRef);

  @override
  Future<void> load() async {
    final isAuthenticated = await _authenticationRepository.autoSignIn();
    final navigationResult =
        isAuthenticated ? NavigateToHome() : NavigateToAuthentication();
    write(navigationResultRef, navigationResult);
  }
}

final navigationResultRef = StateRef<NavigationResult>(null);

class NavigationResult {}

class NavigateToHome extends NavigationResult {}

class NavigateToAuthentication extends NavigationResult {}
