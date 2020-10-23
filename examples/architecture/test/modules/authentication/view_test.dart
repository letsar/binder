import 'package:architecture/modules/app/app.dart';
import 'package:architecture/modules/authentication/logic.dart';
import 'package:architecture/modules/authentication/view.dart';
import 'package:architecture/modules/home/view.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthenticationViewLogic extends Mock
    implements AuthenticationViewLogic {}

AuthenticationViewLogic mockViewLogic;

void main() {
  group('Authentication view', () {
    setUp(() {
      mockViewLogic = MockAuthenticationViewLogic();
    });

    testWidgets(
      'sets username when entering text on UsernameInput',
      (tester) async {
        await tester.pumpWidget(const AuthenticationViewTester());
        await tester.enterText(find.byTypeOf<UsernameInput>(), 'Dark');
        verify(mockViewLogic.username = 'Dark');
      },
    );

    testWidgets(
      'sets password when entering text on PasswordInput',
      (tester) async {
        await tester.pumpWidget(const AuthenticationViewTester());
        await tester.enterText(find.byTypeOf<PasswordInput>(), 'MyPassword');
        verify(mockViewLogic.password = 'MyPassword');
      },
    );

    testWidgets(
      'sets rememberMe when tapping on the Switch',
      (tester) async {
        await tester.pumpWidget(const AuthenticationViewTester());
        await tester.tap(find.byTypeOf<Switch>());
        verify(mockViewLogic.rememberMe = true);

        // We have to manually sets the rememberMe state because the logic is
        // mocked.
        await tester.pumpWidget(const AuthenticationViewTester(
          rememberMe: true,
        ));
        await tester.tap(find.byTypeOf<Switch>());
        verify(mockViewLogic.rememberMe = false);
      },
    );

    testWidgets(
      'calls signIn when tapping on SignInButton',
      (tester) async {
        await tester.pumpWidget(const AuthenticationViewTester());
        await tester.tap(find.byTypeOf<SignInButton>());
        verify(mockViewLogic.signIn());
      },
    );

    testWidgets(
      'displays an AlertDialog when authenticationResult is an '
      'AuthenticationFailure',
      (tester) async {
        await tester.pumpWidget(const AuthenticationViewTester());
        expect(find.byTypeOf<AlertDialog>(), findsNothing);
        await tester.pumpWidget(AuthenticationViewTester(
          authenticationResult: AuthenticationFailure(),
        ));
        await tester.pump();
        expect(find.byTypeOf<AlertDialog>(), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to Home when authenticationResult is an '
      'AuthenticationSuccess',
      (tester) async {
        await tester.pumpWidget(const AuthenticationViewTester());
        expect(find.byTypeOf<AlertDialog>(), findsNothing);
        await tester.pumpWidget(AuthenticationViewTester(
          authenticationResult: AuthenticationSuccess(),
        ));
        await tester.pumpAndSettle();
        expect(find.byTypeOf<HomeView>(), findsOneWidget);
      },
    );
  });
}

extension on CommonFinders {
  Finder byTypeOf<T>() => byType(T);
}

class AuthenticationViewTester extends StatelessWidget {
  const AuthenticationViewTester({
    Key key,
    this.rememberMe = false,
    this.authenticationResult,
  }) : super(key: key);

  final bool rememberMe;
  final AuthenticationResult authenticationResult;

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [
        rememberMeRef.overrideWith(rememberMe),
        authenticationResultRef.overrideWith(authenticationResult),
      ],
      child: App(
        mockHome: AuthenticationView(
          logicOverride: authenticationViewLogicRef.overrideWith((scope) {
            return mockViewLogic;
          }),
        ),
      ),
    );
  }
}
