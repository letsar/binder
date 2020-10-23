import 'package:architecture/data/repositories/authentication.dart';
import 'package:architecture/data/sources/authentication_api_client.dart';
import 'package:architecture/data/sources/preferences.dart';
import 'package:binder/binder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationApiClient extends Mock
    implements AuthenticationApiClient {}

class MockScope extends Mock implements Scope {}

class MockPreferences extends Mock implements Preferences {}

class MockPreference<T> extends Mock implements Preference<T> {}

AuthenticationApiClient mockAuthenticationApi;
Preferences mockPreferences;
Preference<bool> mockRememberMe;
Preference<int> mockLastSignIn;

AuthenticationRepository authenticationRepository;

Scope mockScope;

void main() {
  setUp(() {
    mockAuthenticationApi = MockAuthenticationApiClient();
    mockPreferences = MockPreferences();
    mockScope = MockScope();
    mockRememberMe = MockPreference<bool>();
    mockLastSignIn = MockPreference<int>();

    when(mockPreferences.lastSignIn).thenReturn(mockLastSignIn);
    when(mockPreferences.rememberMe).thenReturn(mockRememberMe);

    when(mockScope.use(authenticationApiClientRef))
        .thenReturn(mockAuthenticationApi);

    when(mockScope.use(preferencesRef)).thenReturn(mockPreferences);

    authenticationRepository = AuthenticationRepository(mockScope);
  });

  group('AuthenticationRepository', () {
    group('autoSignIn()', () {
      test('returns true when all parameters are valid', () async {
        when(mockRememberMe.load()).thenAnswer((_) async => true);
        when(mockLastSignIn.load())
            .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
        when(mockAuthenticationApi.signIn(any, any))
            .thenAnswer((_) async => true);

        expect(await authenticationRepository.autoSignIn(), isTrue);
      });

      test('returns false when rememberMe is null or false', () async {
        when(mockLastSignIn.load())
            .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
        when(mockAuthenticationApi.signIn(any, any))
            .thenAnswer((_) async => true);
        when(mockRememberMe.load()).thenAnswer((_) async => null);
        expect(await authenticationRepository.autoSignIn(), isFalse);
        when(mockRememberMe.load()).thenAnswer((_) async => false);
        expect(await authenticationRepository.autoSignIn(), isFalse);
      });

      test('returns false when mockLastSignIn is null or invalid', () async {
        when(mockRememberMe.load()).thenAnswer((_) async => true);

        when(mockAuthenticationApi.signIn(any, any))
            .thenAnswer((_) async => true);
        when(mockLastSignIn.load()).thenAnswer((_) async => null);
        expect(await authenticationRepository.autoSignIn(), isFalse);
        when(mockLastSignIn.load()).thenAnswer((_) async => DateTime.now()
            .subtract(const Duration(minutes: 6))
            .millisecondsSinceEpoch);
        when(mockRememberMe.load()).thenAnswer((_) async => false);
        expect(await authenticationRepository.autoSignIn(), isFalse);
      });

      test('returns true when api client returns false', () async {
        when(mockRememberMe.load()).thenAnswer((_) async => true);
        when(mockLastSignIn.load())
            .thenAnswer((_) async => DateTime.now().millisecondsSinceEpoch);
        when(mockAuthenticationApi.signIn(any, any))
            .thenAnswer((_) async => false);

        expect(await authenticationRepository.autoSignIn(), isFalse);
      });
    });

    group('signIn()', () {
      test('saves rememberMe and lastSignIn in the preferences', () async {
        when(mockAuthenticationApi.signIn(any, any))
            .thenAnswer((_) async => true);

        expect(
          await authenticationRepository.signIn(
            username: 'username',
            password: 'password',
            rememberMe: true,
          ),
          isTrue,
        );

        verify(mockRememberMe.save(true));
        verify(mockLastSignIn.save(any));
      });
    });

    group('signOut()', () {
      test('calls authenticationApi.signOut() and returns its value', () async {
        when(mockAuthenticationApi.signOut()).thenAnswer((_) async => true);

        expect(
          await authenticationRepository.signOut(),
          isTrue,
        );
      });
    });
  });
}
