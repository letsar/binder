import 'package:binder/src/binder_container.dart';
import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {});

  group('StateRefBase', () {
    test('areEquals calls equalityComparer if not null', () {
      bool equalsCalled = false;
      bool equals(int a, int b) {
        equalsCalled = true;
        return true;
      }

      final intRef = StateRef(4, equalityComparer: equals);
      expect(intRef.equals(3, 6), true);
      expect(equalsCalled, true);
    });

    test('select creates a StateSelector', () {
      int select(int x) => x + 5;
      final intRef = StateRef(4);
      final selector = intRef.select(select) as StateSelector<int, int>;
      expect(selector.ref, intRef);
      expect(selector.equalityComparer, null);
      expect(selector.selector, select);
    });

    test('select creates a StateSelector with the specified equalityComparer',
        () {
      bool equals(int a, int b) {
        return true;
      }

      int select(int x) => x + 5;
      final intRef = StateRef(4);
      final selector = intRef.select(
        select,
        equalityComparer: equals,
      ) as StateSelector<int, int>;
      expect(selector.ref, intRef);
      expect(selector.equalityComparer, equals);
      expect(selector.selector, select);
    });
  });

  group('StateRef', () {
    group('initialState', () {
      test('is provided through the constructor', () {
        final intRef = StateRef(4);
        expect(intRef.initialState, 4);
      });

      test('can be null', () {
        final intRef = StateRef<int>(null);
        expect(intRef.initialState, null);
      });
    });

    group('equalityComparer', () {
      test('is provided through constructor', () {
        bool equals(int a, int b) => false;
        final intRef = StateRef(4, equalityComparer: equals);
        expect(intRef.equalityComparer, equals);
      });

      test('is null if not set through constructor', () {
        final intRef = StateRef(4);
        expect(intRef.equalityComparer, null);
      });
    });

    group('key.name', () {
      test('can be provided through constructor', () {
        final intRef = StateRef(4, name: 'intRef');
        expect(intRef.key.name, 'intRef');
      });

      test('is generated if the name is not set', () {
        final intRef = StateRef(4);
        expect(intRef.key.name, 'StateRef<int>');
      });
    });

    group('override', () {
      test('has the same key', () {
        final intRef = StateRef(4);
        final override = intRef.overrideWith(6);
        expect(intRef.key, override.key);
      });

      test('always creates the provided state', () {
        final intRef = StateRef(4);
        final override = intRef.overrideWith(6);
        expect(override.create(null), 6);
      });
    });

    group('read', () {
      test('calls read with the key and initialState', () {
        final intRef = StateRef(4);
        BinderKey keyArg;
        int initialStateArg;

        T read<T>(BinderKey key, T initialState) {
          keyArg = key;
          initialStateArg = initialState as int;
          return 20 as T;
        }

        expect(intRef.read(read, null), 20);
        expect(keyArg, intRef.key);
        expect(initialStateArg, intRef.initialState);
      });
    });
  });

  group('StateSelector', () {
    group('read', () {
      test('calls read with the key and initialState', () {
        bool selectorCalled = false;
        int selectorStateArg;
        final intRef = StateRef(4);
        final selector = intRef.select((state) {
          selectorCalled = true;
          selectorStateArg = state;
          return state + 7;
        });
        BinderKey keyArg;
        int initialStateArg;

        T read<T>(BinderKey key, T initialState) {
          keyArg = key;
          initialStateArg = initialState as int;
          return 20 as T;
        }

        expect(selector.read(read, null), 27);
        expect(keyArg, intRef.key);
        expect(initialStateArg, intRef.initialState);
        expect(selectorCalled, true);
        expect(selectorStateArg, 20);
      });
    });
  });

  group('Computed', () {
    group('read', () {
      test('calls read multiple times', () {
        bool funcCalled = false;
        final intRef = StateRef(4);
        final stringRef = StateRef('Hello');
        final computed = Computed((watch) {
          funcCalled = true;
          final intState = watch(intRef);
          final stringState = watch(stringRef);
          return '$stringState $intState!';
        });
        final keyArgs = <BinderKey>[];
        final initialStateArgs = <Object>[];

        Type typeOf<T>() => T;

        T read<T>(BinderKey key, T initialState) {
          keyArgs.add(key);
          initialStateArgs.add(initialState);
          final type = typeOf<T>();
          if (type == int) {
            return 8 as T;
          }
          if (type == String) {
            return 'Hey' as T;
          }
          return null;
        }

        expect(computed.read(read, null), 'Hey 8!');
        expect(
            keyArgs,
            containsAllInOrder(<BinderKey>[
              intRef.key,
              stringRef.key,
            ]));
        expect(
            initialStateArgs,
            containsAllInOrder(<Object>[
              intRef.initialState,
              stringRef.initialState,
            ]));
        expect(funcCalled, true);
      });
    });

    testWidgets('throws a StackOverlflowError if circular reference',
        (tester) async {
      Computed<int> computed1;
      Computed<int> computed2;

      computed1 = Computed((watch) {
        final t = watch(computed2) * 2;
        return 2 + t;
      });

      computed2 = Computed((watch) {
        final t = watch(computed1) * 2;
        return 2 * t;
      });

      await tester.pumpWidget(
        BinderScope(
          child: Builder(
            builder: (context) {
              context.watch(computed2);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(tester.takeException(), isA<StackOverflowError>());
    });
  });

  group('LogicRef', () {
    group('create', () {
      test('is provided through the constructor', () {
        int create(Scope scope) => 4;
        final intRef = LogicRef(create);
        expect(intRef.create, create);
      });

      test('cannot be null', () {
        expect(() => LogicRef<int>(null), throwsAssertionError);
      });
    });

    group('key.name', () {
      test('can be provided through constructor', () {
        final intRef = LogicRef((scope) => 4, name: 'intRef');
        expect(intRef.key.name, 'intRef');
      });

      test('is generated if the name is not set', () {
        final intRef = LogicRef((scope) => 4);
        expect(intRef.key.name, 'LogicRef<int>');
      });
    });

    group('override', () {
      test('has the same key', () {
        final intRef = LogicRef((scope) => 4);
        final override = intRef.overrideWith((scope) => 6);
        expect(intRef.key, override.key);
      });

      test('always creates the provided state', () {
        final intRef = LogicRef((scope) => 4);
        final override = intRef.overrideWith((scope) => 6);
        expect(override.create(null), 6);
      });

      test('can be overriden with the same create', () {
        int create(Scope scope) => 4;

        final intRef = LogicRef(create);
        final override = intRef.overrideWithSelf();
        expect(override.create(null), 4);
        expect(override.create, create);
      });
    });
  });
}
