import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DelegatingStateObserver', () {
    testWidgets(
      'An observer should be called for every changes with expected parameters',
      (tester) async {
        BuildContext ctx;
        final logs = <String>[];

        final counterRef = StateRef(0, name: 'counter');

        bool onStateUpdated<T>(
          StateRef<T> ref,
          T oldState,
          T newState,
          Object action,
        ) {
          logs.add(
            '[${ref.key.name}#$action] changed from $oldState to $newState',
          );
          return true;
        }

        await tester.pumpWidget(
          BinderScope(
            observers: [DelegatingStateObserver(onStateUpdated)],
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(logs, isEmpty);
        ctx.write(counterRef, 2, 'a');
        expect(logs, [
          '[counter#a] changed from 0 to 2',
        ]);
        ctx.write(counterRef, 5, 'b');
        expect(logs, [
          '[counter#a] changed from 0 to 2',
          '[counter#b] changed from 2 to 5',
        ]);
      },
    );

    testWidgets(
      'An observer should be called for every changes that occurs below it',
      (tester) async {
        BuildContext ctx;
        final logs = <String>[];

        final counterRef = StateRef(0, name: 'counter');

        bool onStateUpdated<T>(
          StateRef<T> ref,
          T oldState,
          T newState,
          Object action,
        ) {
          logs.add('[${ref.key.name}] changed from $oldState to $newState');
          return true;
        }

        await tester.pumpWidget(
          BinderScope(
            child: BinderScope(
              observers: [DelegatingStateObserver(onStateUpdated)],
              child: Builder(
                builder: (context) {
                  ctx = context;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        expect(logs, isEmpty);
        ctx.write(counterRef, 2);
        expect(logs, ['[counter] changed from 0 to 2']);
      },
    );
  });
}
