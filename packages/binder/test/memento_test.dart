import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:binder/src/logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: invalid_use_of_protected_member

class MementoLogic with Logic {
  const MementoLogic(this.scope);

  @override
  final Scope scope;
}

final m = LogicRef((scope) => MementoLogic(scope));
final a = StateRef(0);
final b = StateRef(0);

void main() {
  group('MementoScope', () {
    test('constructor assertions', () {
      expect(
        () => MementoScope(
          child: null,
        ),
        throwsAssertionError,
      );

      expect(
        () => MementoScope(
          maxCapacity: null,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );

      expect(
        () => MementoScope(
          refs: null,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('undo throws when there is no memento above', (tester) async {
      BuildContext c0;
      await tester.pumpWidget(
        BinderScope(
          child: Builder(
            builder: (context) {
              c0 = context;
              return const SizedBox();
            },
          ),
        ),
      );
      final ml = c0.use(m);

      expect(() => ml.undo(), throwsAssertionError);
    });

    testWidgets('maxCapacity is used ', (tester) async {
      final ml = await tester.pumpMemento(maxCapacity: 1);

      ml.write(a, 3);
      ml.write(a, 4);
      ml.write(a, 5);
      expect(ml.read(a), 5);
      ml.undo();
      ml.undo();
      expect(ml.read(a), 4);
    });

    group('undo', () {
      testWidgets('throws when there is no memento above', (tester) async {
        BuildContext c0;
        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (context) {
                c0 = context;
                return const SizedBox();
              },
            ),
          ),
        );
        final ml = c0.use(m);

        expect(() => ml.undo(), throwsAssertionError);
      });

      testWidgets('writes the previous state', (tester) async {
        final ml = await tester.pumpMemento();

        ml.write(a, 2);
        ml.write(a, 4);
        expect(ml.read(a), 4);
        ml.undo();
        expect(ml.read(a), 2);
      });

      testWidgets('writes the previous state among multiple refs',
          (tester) async {
        final ml = await tester.pumpMemento();

        ml.write(a, 2);
        ml.write(b, 4);
        expect(ml.read(a), 2);
        expect(ml.read(b), 4);
        ml.undo();
        expect(ml.read(a), 2);
        expect(ml.read(b), 0);
      });

      testWidgets('writes the previous state of watched refs', (tester) async {
        final ml = await tester.pumpMemento(refs: [a]);

        ml.write(a, 2);
        ml.write(b, 4);
        expect(ml.read(a), 2);
        expect(ml.read(b), 4);
        ml.undo();
        expect(ml.read(a), 0);
        expect(ml.read(b), 4);
      });

      testWidgets('does nothing if no states', (tester) async {
        final ml = await tester.pumpMemento();
        ml.undo();
      });
    });

    group('redo', () {
      testWidgets('throws when there is no memento above', (tester) async {
        BuildContext c0;
        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (context) {
                c0 = context;
                return const SizedBox();
              },
            ),
          ),
        );
        final ml = c0.use(m);

        expect(() => ml.redo(), throwsAssertionError);
      });

      testWidgets('writes the previously undone state', (tester) async {
        final ml = await tester.pumpMemento();

        ml.write(a, 2);
        ml.write(a, 4);
        expect(ml.read(a), 4);
        ml.undo();
        expect(ml.read(a), 2);
        ml.redo();
        expect(ml.read(a), 4);
      });

      testWidgets('writes the previously undone state among multiple refs',
          (tester) async {
        final ml = await tester.pumpMemento();

        ml.write(a, 2);
        ml.write(b, 4);
        expect(ml.read(a), 2);
        expect(ml.read(b), 4);
        ml.undo();
        expect(ml.read(a), 2);
        expect(ml.read(b), 0);
        ml.redo();
        expect(ml.read(a), 2);
        expect(ml.read(b), 4);
      });

      testWidgets('writes the previously undone state of watched refs',
          (tester) async {
        final ml = await tester.pumpMemento(refs: [a]);

        ml.write(a, 2);
        ml.write(b, 4);
        expect(ml.read(a), 2);
        expect(ml.read(b), 4);
        ml.undo();
        expect(ml.read(a), 0);
        expect(ml.read(b), 4);
        ml.redo();
        expect(ml.read(a), 2);
        expect(ml.read(b), 4);
      });

      testWidgets('does nothing if no states', (tester) async {
        final ml = await tester.pumpMemento();
        ml.redo();
      });

      test('MementoAction.toString concatenates name and action', () {
        const undoAction = UndoAction('test');
        expect(undoAction.toString(), 'undo test');

        const redoAction = RedoAction('test');
        expect(redoAction.toString(), 'redo test');
      });
    });
  });
}

extension on WidgetTester {
  Future<MementoLogic> pumpMemento({
    int maxCapacity,
    List<StateRef> refs,
  }) async {
    BuildContext c0;
    await pumpWidget(
      MementoScope(
        maxCapacity: maxCapacity ?? 256,
        refs: refs ?? [],
        child: Builder(
          builder: (context) {
            c0 = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return c0.use(m);
  }
}
