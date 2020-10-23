import 'package:architecture/data/sources/authentication_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

AuthenticationApiClient authenticationApiClient;

void main() {
  setUp(() {
    authenticationApiClient = AuthenticationApiClient();
  });

  group('AuthenticationApiClient', () {
    test('returns true when signOut is called', () async {
      expect(await authenticationApiClient.signOut(), isTrue);
    });

    test('returns true when signIn is called with valid username and password',
        () async {
      expect(await authenticationApiClient.signIn('test', 'test'), isTrue);
    });

    test('returns false when signIn is called with an invalid username',
        () async {
      expect(await authenticationApiClient.signIn(null, 'password'), isFalse);
      expect(await authenticationApiClient.signIn('', 'password'), isFalse);
    });

    test('returns false when signIn is called with an invalid username',
        () async {
      expect(await authenticationApiClient.signIn('test', null), isFalse);
      expect(await authenticationApiClient.signIn('test', ''), isFalse);
      expect(await authenticationApiClient.signIn('test', 'a'), isFalse);
      expect(await authenticationApiClient.signIn('test', 'aa'), isFalse);
      expect(await authenticationApiClient.signIn('test', 'aaa'), isFalse);
    });
  });
}
