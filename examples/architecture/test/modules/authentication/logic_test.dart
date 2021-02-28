import 'package:architecture/data/repositories/authentication.dart';
import 'package:architecture/modules/authentication/logic.dart';
import 'package:binder/binder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockScope extends Mock implements Scope {}

AuthenticationRepository mockAuthenticationRepository;
Scope mockScope;

AuthenticationViewLogic logic;

void main() {
  setUp(() {
    mockAuthenticationRepository = MockAuthenticationRepository();
    mockScope = MockScope();

    when(mockScope.use(authenticationRepositoryRef))
        .thenReturn(mockAuthenticationRepository);

    logic = AuthenticationViewLogic(mockScope);
  });

  group('AuthenticationViewLogic', () {
    test('username reads and writes to usernameRef ', () {
      logic.username;
      verify(mockScope.read(usernameRef, any));

      logic.username = 'test';
      verify(mockScope.write(usernameRef, 'test'));
    });

    test('password reads and writes to passwordRef ', () {
      logic.password;
      verify(mockScope.read(passwordRef, any));

      logic.password = 'test';
      verify(mockScope.write(passwordRef, 'test'));
    });

    test('rememberMe reads and writes to rememberMeRef ', () {
      logic.rememberMe;
      verify(mockScope.read(rememberMeRef, any));

      logic.rememberMe = false;
      verify(mockScope.write(rememberMeRef, false));
    });

    test('writes AuthenticationSuccess when repository.signIn returns true',
        () async {
      when(mockAuthenticationRepository.signIn(
        username: anyNamed('username'),
        password: anyNamed('password'),
        rememberMe: anyNamed('rememberMe'),
      )).thenAnswer((_) async => true);
      await logic.signIn();
      verify(mockScope.write(
        authenticationResultRef,
        argThat(isA<AuthenticationSuccess>()),
      ));
    });

    test('writes AuthenticationFailure when repository.signIn returns false',
        () async {
      when(mockAuthenticationRepository.signIn(
        username: anyNamed('username'),
        password: anyNamed('password'),
        rememberMe: anyNamed('rememberMe'),
      )).thenAnswer((_) async => false);
      await logic.signIn();
      verify(mockScope.write(
        authenticationResultRef,
        argThat(isA<AuthenticationFailure>()),
      ));
    });
  });
}
