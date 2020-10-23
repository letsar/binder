import 'package:architecture/modules/app/app.dart';
import 'package:architecture/modules/authentication/view.dart';
import 'package:architecture/modules/home/view.dart';
import 'package:architecture/modules/splash/logic.dart';
import 'package:architecture/modules/splash/view.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockSplashViewLogic extends Mock implements SplashViewLogic {}

SplashViewLogic mockViewLogic;

void main() {
  group('Splash view', () {
    setUp(() {
      mockViewLogic = MockSplashViewLogic();
    });

    testWidgets(
      'calls load when appearing',
      (tester) async {
        await tester.pumpWidget(const SplashViewTester());
        verify(mockViewLogic.load());
      },
    );

    testWidgets(
      'navigates to home when navigationResult is '
      'NavigateToHome',
      (tester) async {
        await tester.pumpWidget(const SplashViewTester());
        await tester.pumpWidget(SplashViewTester(
          navigationResult: NavigateToHome(),
        ));
        await tester.pumpAndSettle();
        expect(find.byTypeOf<HomeView>(), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to authenticaiton when navigationResult is '
      'NavigateToAuthentication',
      (tester) async {
        await tester.pumpWidget(const SplashViewTester());
        await tester.pumpWidget(SplashViewTester(
          navigationResult: NavigateToAuthentication(),
        ));
        await tester.pumpAndSettle();
        expect(find.byTypeOf<AuthenticationView>(), findsOneWidget);
      },
    );
  });
}

extension on CommonFinders {
  Finder byTypeOf<T>() => byType(T);
}

class SplashViewTester extends StatelessWidget {
  const SplashViewTester({
    Key key,
    this.navigationResult,
  }) : super(key: key);

  final NavigationResult navigationResult;

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [
        navigationResultRef.overrideWith(navigationResult),
        splashViewLogicRef.overrideWith((scope) => mockViewLogic),
      ],
      child: const App(
        mockHome: SplashView(),
      ),
    );
  }
}
