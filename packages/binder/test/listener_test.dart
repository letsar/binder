import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:binder/src/listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValueWatcher', () {
    test('constructor assertions', () {
      expect(
        () => ValueListener(
          value: 3,
          onValueChanged: (_, int __) {},
          child: null,
        ),
        throwsAssertionError,
      );

      expect(
        () => ValueListener(
          value: 3,
          onValueChanged: null,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders a child', (tester) async {
      await tester.pumpWidget(
        ValueListener(
          value: 3,
          onValueChanged: (_, int __) {},
          child: const Text(
            'watcher',
            textDirection: TextDirection.ltr,
          ),
        ),
      );

      expect(find.text('watcher'), findsOneWidget);
    });

    testWidgets('calls onValueChanged when value changed', (tester) async {
      final logs = <int>[];

      await tester.pumpWidget(
        ValueListener(
          value: 4,
          onValueChanged: (_, int state) {
            logs.add(state);
          },
          child: const SizedBox(),
        ),
      );

      expect(logs, <int>[]);

      await tester.pumpWidget(
        ValueListener(
          value: 5,
          onValueChanged: (_, int state) {
            logs.add(state);
          },
          child: const SizedBox(),
        ),
      );

      expect(logs, <int>[5]);
    });
  });

  group('Watcher', () {
    test('constructor assertions', () {
      final a = StateRef(0);

      expect(
        () => StateListener<int>(
          watchable: null,
          onStateChanged: (_, int __) {},
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );

      expect(
        () => StateListener(
          watchable: a,
          onStateChanged: (_, int __) {},
          child: null,
        ),
        throwsAssertionError,
      );

      expect(
        () => StateListener(
          watchable: a,
          onStateChanged: null,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders a ValueWatcher', (tester) async {
      final a = StateRef(0);

      await tester.pumpWidget(
        BinderScope(
          child: StateListener(
            watchable: a,
            onStateChanged: (_, int __) {},
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byTypeOf<ValueListener<int>>(), findsOneWidget);
    });

    testWidgets('calls onStateChanged when state changed', (tester) async {
      final a = StateRef(0);
      final logs = <int>[];
      BuildContext c0;

      await tester.pumpWidget(
        BinderScope(
          child: StateListener(
            watchable: a,
            onStateChanged: (_, int state) {
              logs.add(state);
            },
            child: Builder(
              builder: (context) {
                c0 = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      c0.write(a, 5);
      expect(logs, <int>[]);

      await tester.pump();
      expect(logs, <int>[5]);
    });
  });
}

extension on CommonFinders {
  Finder byTypeOf<T>() => byType(T);
}
