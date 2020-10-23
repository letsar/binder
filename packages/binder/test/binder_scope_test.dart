import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:binder/src/observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: missing_whitespace_between_adjacent_strings

void main() {
  group('BinderScope', () {
    test('must have a child', () {
      expect(
        () => BinderScope(child: null),
        throwsAssertionError,
      );
    });

    test('overrides cannot be null', () {
      expect(
        () => BinderScope(overrides: null, child: null),
        throwsAssertionError,
      );
    });

    test('observers cannot be null', () {
      expect(
        () => BinderScope(observers: null, child: null),
        throwsAssertionError,
      );
    });

    testWidgets('throws when there is no BinderScope above', (tester) async {
      final a = StateRef(4);
      final b = LogicRef((scope) => null);
      BuildContext c0;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            c0 = c;
            return const SizedBox();
          },
        ),
      );

      expect(() => c0.read(a), throwsStateError);
      expect(() => c0.write(a, 8), throwsStateError);
      expect(() => c0.use(b), throwsStateError);
    });

    testWidgets('do not save a StateRef initialState', (tester) async {
      final intRef = StateRef(4);
      BuildContext c0;
      await tester.pumpWidget(
        BinderScope(
          child: Builder(
            builder: (c) {
              c0 = c;
              return const SizedBox();
            },
          ),
        ),
      );

      final state = c0.findAncestorStateOfType<BinderScopeState>();
      expect(state.states.containsKey(intRef.key), false);
      c0.read(intRef);
      expect(state.states.containsKey(intRef.key), false);
    });

    testWidgets('saves a StateRef state by writing it', (tester) async {
      final intRef = StateRef(4);
      BuildContext c0;
      await tester.pumpWidget(
        BinderScope(
          child: Builder(
            builder: (c) {
              c0 = c;
              return const SizedBox();
            },
          ),
        ),
      );

      final state = c0.findAncestorStateOfType<BinderScopeState>();
      expect(state.states.containsKey(intRef.key), false);
      expect(c0.read(intRef), 4);
      c0.write(intRef, 8);
      expect(c0.read(intRef), 8);
      expect(state.states.containsKey(intRef.key), true);
    });

    testWidgets('is kept alive in scrolling widgets', (tester) async {
      BuildContext c0;
      await tester.pumpWidget(
        BinderScope(
          child: Builder(
            builder: (c) {
              c0 = c;
              return const SizedBox();
            },
          ),
        ),
      );

      final state = c0.findAncestorStateOfType<BinderScopeState>();
      expect(state is AutomaticKeepAliveClientMixin<BinderScope>, true);
      expect(state.wantKeepAlive, true);
    });

    testWidgets('calling clear, removes a state', (tester) async {
      final a = StateRef(0);

      BuildContext ctx;
      await tester.pumpWidget(
        BinderScope(
          child: BinderScope(
            child: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      ctx.write(a, 4);
      expect(ctx.read(a), 4);

      final state = ctx.findAncestorStateOfType<BinderScopeState>();
      state.clear(a);
      expect(ctx.read(a), 0);
      expect(state.states.containsKey(a.key), isFalse);
    });

    testWidgets('calling use, creates the logic', (tester) async {
      final a = LogicRef((scope) => 4);

      BuildContext c0;
      BuildContext c1;
      await tester.pumpWidget(
        BinderScope(
          child: Builder(builder: (context) {
            c0 = context;
            return BinderScope(
              child: Builder(
                builder: (c) {
                  c1 = c;
                  return const SizedBox();
                },
              ),
            );
          }),
        ),
      );

      final state1 = c1.findAncestorStateOfType<BinderScopeState>();

      expect(state1.states.containsKey(a.key), isFalse);
      expect(c1.use(a), 4);
      expect(state1.states.containsKey(a.key), isFalse);

      final state0 = c0.findAncestorStateOfType<BinderScopeState>();
      expect(state0.states.containsKey(a.key), isTrue);
    });

    group('watch', () {
      testWidgets(
        'throws when called outside of a build method',
        (tester) async {
          final a = StateRef(0);

          BuildContext c0;
          await tester.pumpWidget(
            BinderScope(
              child: Builder(
                builder: (c) {
                  c0 = c;
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(() => c0.watch(a), throwsAssertionError);
        },
      );

      testWidgets(
        'can be called on a StateRef',
        (tester) async {
          final a = StateRef(0);

          int state;
          int buildCount = 0;

          BuildContext c0;
          await tester.pumpWidget(
            BinderScope(
              child: Builder(
                builder: (c) {
                  c0 = c;
                  buildCount++;
                  state = c.watch(a);
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(state, 0);
          expect(buildCount, 1);
          c0.write(a, 8);
          // state is updated after a rebuild.
          expect(state, 0);
          expect(buildCount, 1);

          await tester.pump();

          expect(state, 8);
          expect(buildCount, 2);
        },
      );

      testWidgets(
        'rebuilds only when the value watched changes',
        (tester) async {
          final a = StateRef(0);
          final b = StateRef(0);

          int state;
          int buildCount = 0;

          BuildContext c0;
          await tester.pumpWidget(
            BinderScope(
              child: Builder(
                builder: (c) {
                  c0 = c;
                  buildCount++;
                  state = c.watch(a);
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(state, 0);
          expect(buildCount, 1);
          c0.write(b, 8);
          await tester.pump();
          expect(state, 0);
          expect(buildCount, 1);
        },
      );

      testWidgets(
        'can be called on a StateRef.select',
        (tester) async {
          final a = StateRef(0);

          int state;
          int buildCount = 0;

          BuildContext c0;
          await tester.pumpWidget(
            BinderScope(
              child: Builder(
                builder: (c) {
                  c0 = c;
                  buildCount++;
                  state = c.watch(a.select((state) => state * 2));
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(state, 0);
          expect(buildCount, 1);
          c0.write(a, 8);
          // state is updated after a rebuild.
          expect(state, 0);
          expect(buildCount, 1);

          await tester.pump();

          expect(state, 16);
          expect(buildCount, 2);
        },
      );

      testWidgets(
        'can be called on a Computed',
        (tester) async {
          final a = StateRef(2);
          final b = StateRef(7);
          final c = Computed((watch) {
            return watch(a) * watch(b);
          });

          num state;
          int buildCount = 0;

          BuildContext c0;
          await tester.pumpWidget(
            BinderScope(
              child: Builder(
                builder: (context) {
                  c0 = context;
                  buildCount++;
                  state = context.watch(c);
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(state, 14);
          expect(buildCount, 1);
          c0.write(a, 8);
          await tester.pump();
          expect(state, 56);
          expect(buildCount, 2);
          c0.write(b, 0);
          await tester.pump();
          expect(state, 0);
          expect(buildCount, 3);
          c0.write(a, 54);
          await tester.pump();
          expect(state, 0);
          expect(buildCount, 3);
        },
      );
    });

    group('overrides', () {
      testWidgets('- states are direclty saved', (tester) async {
        final intRef = StateRef(4);
        BuildContext c0;
        await tester.pumpWidget(
          BinderScope(
            overrides: [intRef.overrideWith(5)],
            child: Builder(
              builder: (c) {
                c0 = c;
                return const SizedBox();
              },
            ),
          ),
        );

        final state = c0.findAncestorStateOfType<BinderScopeState>();
        expect(state.states.containsKey(intRef.key), true);
        expect(c0.read(intRef), 5);
      });

      testWidgets('are scoped to scope', (tester) async {
        final intRef = StateRef(4);
        BuildContext c0;
        BuildContext c1;
        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (c) {
                c0 = c;
                return BinderScope(
                  overrides: [intRef.overrideWith(5)],
                  child: Builder(
                    builder: (c) {
                      c1 = c;
                      return const SizedBox();
                    },
                  ),
                );
              },
            ),
          ),
        );

        expect(c0.read(intRef), 4);
        expect(c1.read(intRef), 5);

        c0.write(intRef, 42);
        expect(c0.read(intRef), 42);
        expect(c1.read(intRef), 5);

        c1.write(intRef, 52);
        expect(c0.read(intRef), 42);
        expect(c1.read(intRef), 52);
      });

      testWidgets('- states before the didUpdateWidget are kept',
          (tester) async {
        final a = StateRef(0);
        final b = StateRef(0);
        BuildContext ctx;

        await tester.pumpWidget(
          BinderScope(
            overrides: [
              a.overrideWith(5),
            ],
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        ctx.write(a, 10);
        expect(ctx.read(a), 10);

        await tester.pumpWidget(
          BinderScope(
            overrides: [
              a.overrideWith(5),
              b.overrideWith(1),
            ],
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(a), 10);
      });

      testWidgets(
        'are updated only if the state has never been updated',
        (tester) async {
          final a = StateRef(0);
          final b = StateRef(0);
          BuildContext ctx;

          await tester.pumpWidget(
            BinderScope(
              overrides: [
                a.overrideWith(5),
                b.overrideWith(10),
              ],
              child: Builder(
                builder: (context) {
                  ctx = context;
                  return const SizedBox();
                },
              ),
            ),
          );

          ctx.write(a, 2);
          expect(ctx.read(a), 2);
          ctx.write(a, 5);
          expect(ctx.read(a), 5);

          await tester.pumpWidget(
            BinderScope(
              overrides: [
                a.overrideWith(8),
                b.overrideWith(15),
              ],
              child: Builder(
                builder: (context) {
                  ctx = context;
                  return const SizedBox();
                },
              ),
            ),
          );

          expect(ctx.read(a), 5);
          expect(ctx.read(b), 15);
        },
      );

      testWidgets('- states are removed when the override is removed',
          (tester) async {
        final a = StateRef(0);
        BuildContext ctx;

        await tester.pumpWidget(
          BinderScope(
            overrides: [
              a.overrideWith(5),
            ],
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(a), 5);

        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(a), 0);
        expect(
          ctx
              .findAncestorStateOfType<BinderScopeState>()
              .states
              .containsKey(a.key),
          isFalse,
        );
      });

      testWidgets('- new overrides are added', (tester) async {
        final a = StateRef(0);
        final b = StateRef(0);
        BuildContext ctx;

        await tester.pumpWidget(
          BinderScope(
            overrides: [
              a.overrideWith(5),
            ],
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(a), 5);
        expect(ctx.read(b), 0);

        await tester.pumpWidget(
          BinderScope(
            overrides: [
              a.overrideWith(5),
              b.overrideWith(10),
            ],
            child: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(a), 5);
        expect(ctx.read(b), 10);
      });
    });

    group('debugFillProperties', () {
      testWidgets('list nothing if state is not written', (tester) async {
        final unnamed = StateRef(0);
        final named = StateRef(6, name: 'named');
        final scopeKey = GlobalKey();

        await tester.pumpWidget(
          BinderScope(
            key: scopeKey,
            child: Builder(
              builder: (context) {
                context.watch(unnamed);
                context.watch(named);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(
          scopeKey.currentContext.toString(),
          equalsIgnoringHashCodes(
            'BinderScope-[GlobalKey#00000]('
            'overrides: [], '
            'observers: [], '
            'state: BinderScopeState#00000)',
          ),
        );
      });

      testWidgets('list states when written', (tester) async {
        final unnamed = StateRef(0);
        final named = StateRef(6, name: 'named');
        final scopeKey = GlobalKey();
        BuildContext c0;

        await tester.pumpWidget(
          BinderScope(
            key: scopeKey,
            child: Builder(
              builder: (context) {
                c0 = context;
                context.watch(unnamed);
                context.watch(named);
                return const SizedBox();
              },
            ),
          ),
        );

        c0.write(unnamed, 5);
        c0.write(named, 10);

        await tester.pump();

        expect(
          scopeKey.currentContext.toString(),
          equalsIgnoringHashCodes(
            'BinderScope-[GlobalKey#00000]('
            'overrides: [], '
            'observers: [], '
            'state: BinderScopeState#00000('
            'StateRef<int>: 5, '
            'named: 10))',
          ),
        );
      });

      testWidgets('list overrides, observers and states', (tester) async {
        final unnamed = StateRef(0);
        final named = StateRef(6, name: 'named');
        final scopeKey = GlobalKey();

        await tester.pumpWidget(
          BinderScope(
            key: scopeKey,
            overrides: [
              unnamed.overrideWith(5),
              named.overrideWith(3),
            ],
            observers: const [DelegatingStateObserver(null)],
            child: Builder(
              builder: (context) {
                context.watch(unnamed);
                context.watch(named);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(
          scopeKey.currentContext.toString(),
          equalsIgnoringHashCodes(
            'BinderScope-[GlobalKey#00000]('
            'overrides: [StateRef<int>, named], '
            'observers: [DelegatingStateObserver#00000], '
            'state: BinderScopeState#00000('
            'StateRef<int>: 5, '
            'named: 3))',
          ),
        );
      });
    });
  });
}
