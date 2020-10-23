import 'package:architecture/data/repositories/authentication.dart';
import 'package:architecture/modules/splash/logic.dart';
import 'package:binder/binder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockScope extends Mock implements Scope {}

AuthenticationRepository mockAuthenticationRepository;
Scope mockScope;

SplashViewLogic logic;

void main() {
  setUp(() {
    mockAuthenticationRepository = MockAuthenticationRepository();
    mockScope = MockScope();

    when(mockScope.use(authenticationRepositoryRef))
        .thenReturn(mockAuthenticationRepository);

    logic = SplashViewLogic(mockScope);
  });

  group('SplashViewLogic', () {
    test(
      'writes NavigateToAuthentication to navigationResultRef when autoSignIn '
      'returns false',
      () async {
        when(mockAuthenticationRepository.autoSignIn())
            .thenAnswer((_) async => false);

        await logic.load();

        verify(mockScope.write(
          navigationResultRef,
          argThat(isA<NavigateToAuthentication>()),
        ));
      },
    );

    test(
      'writes NavigateToHome to navigationResultRef when autoSignIn '
      'returns true',
      () async {
        when(mockAuthenticationRepository.autoSignIn())
            .thenAnswer((_) async => true);

        await logic.load();

        verify(mockScope.write(
          navigationResultRef,
          argThat(isA<NavigateToHome>()),
        ));
      },
    );
  });
}
