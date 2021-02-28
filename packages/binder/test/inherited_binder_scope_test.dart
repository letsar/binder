import 'package:binder/src/binder_container.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore: must_be_immutable
class MockStateRefBase<T> extends Mock implements Watchable<T> {}

Watchable<int> ref;

void main() {
  setUp(() {
    ref = MockStateRefBase();
  });

  group('Aspect', () {
    test('shouldRebuild returns false if states are considered equals', () {
      when(ref.equals(1, 1)).thenReturn(true);
      when(ref.read(any, any)).thenReturn(1);

      final aspect = Aspect(ref, null);
      final shouldRebuild = aspect.shouldRebuild(null, null);
      expect(shouldRebuild, false);
    });

    test('shouldRebuild returns true if states are not considered equals', () {
      when(ref.equals(1, 1)).thenReturn(false);
      when(ref.read(any, any)).thenReturn(1);

      final aspect = Aspect(ref, null);
      final shouldRebuild = aspect.shouldRebuild(null, null);
      expect(shouldRebuild, true);
    });
  });

  group('InheritedBinderScope', () {
    test('container and child cannot be null ', () {
      // We expect that the binder can be null.
      const InheritedBinderScope(
        container: BinderContainer(null, null),
        scope: null,
        writtenKeys: {},
        child: SizedBox(),
      );

      expect(
        () => InheritedBinderScope(
          container: null,
          scope: null,
          writtenKeys: const {},
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );

      expect(
        () => InheritedBinderScope(
          container: const BinderContainer(null, null),
          scope: null,
          child: null,
          writtenKeys: const {},
        ),
        throwsAssertionError,
      );

      expect(
        () => InheritedBinderScope(
          container: const BinderContainer(null, null),
          scope: null,
          writtenKeys: null,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('do not notify when container are the same', () {
      const oldWidget = InheritedBinderScope(
        container: BinderContainer(null, null),
        scope: null,
        writtenKeys: {},
        child: SizedBox(),
      );

      const newWidget = InheritedBinderScope(
        container: BinderContainer(null, null),
        scope: null,
        writtenKeys: {},
        child: SizedBox(),
      );

      expect(newWidget.updateShouldNotify(oldWidget), false);
    });

    test('can notify when container are different', () {
      const oldWidget = InheritedBinderScope(
        container: BinderContainer({null: 6}, null),
        scope: null,
        writtenKeys: {},
        child: SizedBox(),
      );

      const newWidget = InheritedBinderScope(
        container: BinderContainer({null: 4}, null),
        scope: null,
        writtenKeys: {},
        child: SizedBox(),
      );

      expect(newWidget.updateShouldNotify(oldWidget), true);
    });

    test('do not notify if state not saved', () {
      final intRef1 = StateRef(1);
      final intRef2 = StateRef(2);

      final oldState = {
        intRef1.key: 6,
      };

      final newState = {
        intRef1.key: 7,
      };

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: null,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: {intRef1.key, intRef2.key},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([Aspect<int>(intRef2, null)]),
        ),
        false,
      );
    });

    test('do not notify if state not changed', () {
      final intRef1 = StateRef(1);

      final oldState = {
        intRef1.key: 6,
      };

      final newState = {
        intRef1.key: 6,
      };

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: null,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: {intRef1.key},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([
            Aspect<int>(intRef1, [intRef1.key])
          ]),
        ),
        false,
      );
    });

    test('notifies if state changed', () {
      final intRef1 = StateRef(1);

      final oldState = {
        intRef1.key: 6,
      };

      final newState = {
        intRef1.key: 7,
      };

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: null,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: {intRef1.key},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([
            Aspect<int>(intRef1, [intRef1.key])
          ]),
        ),
        true,
      );
    });

    test('notifies if at least one state changed', () {
      final intRef1 = StateRef(1);
      final intRef2 = StateRef(2);

      final oldState = {
        intRef1.key: 6,
        intRef2.key: 8,
      };

      final newState = {
        intRef1.key: 6,
        intRef2.key: 0,
      };

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: null,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: {intRef1.key, intRef2.key},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([
            Aspect<int>(intRef1, [intRef1.key]),
            Aspect<int>(intRef2, [intRef2.key]),
          ]),
        ),
        true,
      );
    });

    test('notify only if written keys matches updates', () {
      final intRef1 = StateRef(1);
      final intRef2 = StateRef(2);

      final oldState = {
        intRef1.key: 6,
        intRef2.key: 8,
      };

      final newState = {
        intRef1.key: 6,
        intRef2.key: 0,
      };

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: null,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      var newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([
            Aspect<int>(intRef1, [intRef1.key]),
            Aspect<int>(intRef2, [intRef2.key]),
          ]),
        ),
        false,
      );

      newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: {intRef1.key},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([
            Aspect<int>(intRef1, [intRef1.key]),
            Aspect<int>(intRef2, [intRef2.key]),
          ]),
        ),
        false,
      );

      newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: null,
        writtenKeys: {intRef2.key},
        child: const SizedBox(),
      );

      expect(
        newWidget.updateShouldNotifyDependent(
          oldWidget,
          Dependencies([
            Aspect<int>(intRef1, [intRef1.key]),
            Aspect<int>(intRef2, [intRef2.key]),
          ]),
        ),
        true,
      );
    });
  });
}
