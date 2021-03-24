import 'package:binder/src/binder_container.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore: must_be_immutable
class MockStateRefBase<T> extends Mock implements Watchable<T> {}

final Watchable<int> ref = MockStateRefBase();

void main() {
  setUp(() {
    reset(ref);
  });

  group('Aspect', () {
    test('shouldRebuild returns false if states are considered equals', () {
      T read<T>(BinderKey key, T state) {
        return state;
      }

      when(() => ref.equals(1, 1)).thenReturn(true);
      when(() => ref.read(read, any())).thenReturn(1);

      final aspect = Aspect(ref, null);
      final shouldRebuild = aspect.shouldRebuild(read, read);
      expect(shouldRebuild, false);
    });

    test('shouldRebuild returns true if states are not considered equals', () {
      T read<T>(BinderKey key, T state) {
        return state;
      }

      when(() => ref.equals(1, 1)).thenReturn(false);
      when(() => ref.read(read, any())).thenReturn(1);

      final aspect = Aspect(ref, null);
      final shouldRebuild = aspect.shouldRebuild(read, read);
      expect(shouldRebuild, true);
    });
  });

  group('InheritedBinderScope', () {
    test('do not notify when container are the same', () {
      const container = BinderContainer(<BinderKey, Object?>{}, null);
      final scope = MockScope();
      final oldWidget = InheritedBinderScope(
        container: container,
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: container,
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      expect(newWidget.updateShouldNotify(oldWidget), false);
    });

    test('can notify when container are different', () {
      final scope = MockScope();

      final oldWidget = InheritedBinderScope(
        container: const BinderContainer({BinderKey(''): 6}, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: const BinderContainer({BinderKey(''): 4}, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
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

      final scope = MockScope();

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: scope,
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

      final scope = MockScope();

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: scope,
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

      final scope = MockScope();

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: scope,
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

      final scope = MockScope();

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      final newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: scope,
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

      final scope = MockScope();

      final oldWidget = InheritedBinderScope(
        container: BinderContainer(oldState, null),
        scope: scope,
        writtenKeys: const {},
        child: const SizedBox(),
      );

      var newWidget = InheritedBinderScope(
        container: BinderContainer(newState, null),
        scope: scope,
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
        scope: scope,
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
        scope: scope,
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
