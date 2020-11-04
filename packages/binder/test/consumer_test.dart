import 'package:binder/binder.dart';
import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Consumer', () {
    test('arguments control', () {
      const child = SizedBox();
      Widget build(BuildContext context, int value, Widget child) {
        return child;
      }

      final a = StateRef(0);

      expect(
        () => Consumer(watchable: null, builder: build, child: child),
        throwsAssertionError,
      );

      expect(
        () => Consumer(watchable: a, builder: null, child: child),
        throwsAssertionError,
      );

      // Don't throw.
      Consumer(watchable: a, builder: build, child: null);
    });

    testWidgets('works with StateRef', (tester) async {
      final logs = <String>[];
      final a = StateRef(0);
      BuildContext ctx;
      int v;

      await tester.pumpWidget(
        BinderScope(
          child: Builder(builder: (_) {
            logs.add('parent');
            return Consumer(
              watchable: a,
              builder: (context, int value, child) {
                v = value;
                ctx = context;
                logs.add('consumer');
                return child;
              },
              child: Builder(
                builder: (_) {
                  logs.add('child');
                  return const SizedBox();
                },
              ),
            );
          }),
        ),
      );

      expect(logs, ['parent', 'consumer', 'child']);
      expect(v, 0);
      logs.clear();
      ctx.write(a, 2);
      await tester.pump();
      expect(v, 2);
      expect(logs, ['consumer']);
    });

    testWidgets('works with select', (tester) async {
      final logs = <String>[];
      final a = StateRef(0);
      BuildContext ctx;
      int v;

      await tester.pumpWidget(
        BinderScope(
          child: Builder(builder: (_) {
            logs.add('parent');
            return Consumer(
              watchable: a.select((state) => state + 4),
              builder: (context, int value, child) {
                v = value;
                ctx = context;
                logs.add('consumer');
                return child;
              },
              child: Builder(
                builder: (_) {
                  logs.add('child');
                  return const SizedBox();
                },
              ),
            );
          }),
        ),
      );

      expect(logs, ['parent', 'consumer', 'child']);
      expect(v, 4);
      logs.clear();
      ctx.write(a, 2);
      await tester.pump();
      expect(v, 6);
      expect(logs, ['consumer']);
    });

    testWidgets('works with Computed', (tester) async {
      final logs = <String>[];
      final b = StateRef(0);
      final a = Computed((watch) => watch(b) + 4);

      BuildContext ctx;
      int v;

      await tester.pumpWidget(
        BinderScope(
          child: Builder(builder: (_) {
            logs.add('parent');
            return Consumer(
              watchable: a,
              builder: (context, int value, child) {
                v = value;
                ctx = context;
                logs.add('consumer');
                return child;
              },
              child: Builder(
                builder: (_) {
                  logs.add('child');
                  return const SizedBox();
                },
              ),
            );
          }),
        ),
      );

      expect(logs, ['parent', 'consumer', 'child']);
      expect(v, 4);
      logs.clear();
      ctx.write(b, 2);
      await tester.pump();
      expect(v, 6);
      expect(logs, ['consumer']);
    });
  });
}
