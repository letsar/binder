// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter/main.dart';
import 'package:mockito/mockito.dart';

class FakeHomeLogic extends Mock implements HomeLogic {}

class MockScope extends Mock implements Scope {}

void main() {
  test('Test your logic by mocking the Binder', () {
    final scope = MockScope();
    when(scope.read(counterRef, any)).thenReturn(99);

    final homeLogic = HomeLogic(scope);

    homeLogic.increment();
    verify(scope.read(counterRef, any));
    verify(scope.write(counterRef, 100));
  });

  testWidgets('Test your view by mocking your logic', (tester) async {
    final homeLogic = FakeHomeLogic();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      BinderScope(
        overrides: [homeLogicRef.overrideWith((scope) => homeLogic)],
        child: const MyApp(),
      ),
    );

    // Tap the '+' icon and verify that increment is called.
    await tester.tap(find.byIcon(Icons.add));
    verify(homeLogic.increment());
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
