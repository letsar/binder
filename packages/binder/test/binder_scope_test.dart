import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: missing_whitespace_between_adjacent_strings

void main() {
  group('BinderScope', () {
    testWidgets('throws when there is no BinderScope above', (tester) async {
      final a = StateRef(4);
      final b = LogicRef((scope) => null);
      late BuildContext c0;
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
      late BuildContext c0;
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

      final state = c0.findAncestorStateOfType<BinderScopeState>()!;
      expect(state.states.containsKey(intRef.key), false);
      c0.read(intRef);
      expect(state.states.containsKey(intRef.key), false);
    });

    testWidgets('saves a StateRef state by writing it', (tester) async {
      final intRef = StateRef(4);
      late BuildContext c0;
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

      final state = c0.findAncestorStateOfType<BinderScopeState>()!;
      expect(state.states.containsKey(intRef.key), false);
      expect(c0.read(intRef), 4);
      c0.write(intRef, 8);
      expect(c0.read(intRef), 8);
      expect(state.states.containsKey(intRef.key), true);
    });

    testWidgets('is kept alive in scrolling widgets', (tester) async {
      late BuildContext c0;
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

      final state = c0.findAncestorStateOfType<BinderScopeState>()!;
      expect(state is AutomaticKeepAliveClientMixin<BinderScope>, true);
      expect(state.wantKeepAlive, true);
    });

    testWidgets('calling clear, removes a state', (tester) async {
      final a = StateRef(0);

      late BuildContext ctx;
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

      final state = ctx.findAncestorStateOfType<BinderScopeState>()!;
      state.clear(a);
      expect(ctx.read(a), 0);
      expect(state.states.containsKey(a.key), isFalse);
    });

    testWidgets('calling use, creates the logic', (tester) async {
      final a = LogicRef((scope) => 4);

      late BuildContext c0;
      late BuildContext c1;
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

      final state1 = c1.findAncestorStateOfType<BinderScopeState>()!;

      expect(state1.states.containsKey(a.key), isFalse);
      expect(c1.use(a), 4);
      expect(state1.states.containsKey(a.key), isFalse);

      final state0 = c0.findAncestorStateOfType<BinderScopeState>()!;
      expect(state0.states.containsKey(a.key), isTrue);
    });

    group('read', () {
      testWidgets('can be used with StateRef', (tester) async {
        final a = StateRef(0);

        late BuildContext ctx;
        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(a), 0);
        ctx.write(a, 2);
        expect(ctx.read(a), 2);
      });

      testWidgets('can be used with Selector', (tester) async {
        final a = StateRef(0);
        final selector = a.select((state) => state + 3);

        late BuildContext ctx;
        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(selector), 3);
        ctx.write(a, 2);
        expect(ctx.read(selector), 5);
      });

      testWidgets('can be used with Computed', (tester) async {
        final a = StateRef(0);
        final computed = Computed((watch) => watch(a) + 3);

        late BuildContext ctx;
        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(ctx.read(computed), 3);
        ctx.write(a, 2);
        expect(ctx.read(computed), 5);
      });
    });

    group('watch', () {
      testWidgets(
        'throws when called outside of a build method',
        (tester) async {
          final a = StateRef(0);

          late BuildContext c0;
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

          int? state;
          int buildCount = 0;

          late BuildContext c0;
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

          int? state;
          int buildCount = 0;

          late BuildContext c0;
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

          int? state;
          int buildCount = 0;

          late BuildContext c0;
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

          num? state;
          int buildCount = 0;

          late BuildContext c0;
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

      testWidgets('old selectors must be removed after a rebuild',
          (tester) async {
        int counter = 0;
        final ref = StateRef(0);

        await tester.pumpWidget(BinderScope(
          child: Builder(
            builder: (context) {
              context.watch(ref.select((state) {
                counter++;
                return state + 4;
              }));
              return const SizedBox();
            },
          ),
        ));

        expect(counter, 1);

        await tester.pumpWidget(BinderScope(
          child: Builder(
            builder: (context) {
              context.watch(ref.select((state) {
                counter++;
                return state + 4;
              }));
              return const SizedBox();
            },
          ),
        ));

        await tester.pumpWidget(BinderScope(
          child: Builder(
            builder: (context) {
              context.watch(ref.select((state) {
                counter++;
                return state + 4;
              }));
              return const SizedBox();
            },
          ),
        ));

        // The counter may be less in the future.
        expect(counter, 3);
      });

      testWidgets('only impacted selectors are called', (tester) async {
        final a = StateRef(0);
        final b = StateRef(0);

        final logs = <String>[];
        late BuildContext ctx;

        final builder = Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        });

        final bWidget = Builder(builder: (context) {
          context.watch(b.select((state) {
            logs.add('b');
            return state + 4;
          }));
          return builder;
        });

        final aWidget = Builder(builder: (context) {
          context.watch(a.select((state) {
            logs.add('a');
            return state + 2;
          }));
          return bWidget;
        });

        await tester.pumpWidget(
          BinderScope(
            // We override the states because we want them to be stored right now.
            overrides: [
              a.overrideWith(1),
              b.overrideWith(3),
            ],
            child: aWidget,
          ),
        );

        expect(ctx.read(a), 1);
        expect(ctx.read(b), 3);

        expect(logs, ['a', 'b']);

        ctx.write(a, 4);
        await tester.pump();

        // The `a` selector is runned twice before the rebuild of the widget
        // because we run it for the old state and the new one.
        expect(logs, ['a', 'b', 'a', 'a', 'a']);
      });

      testWidgets('only impacted computed are called', (tester) async {
        final logs = <String>[];
        final a = StateRef(0);
        final b = StateRef(0);

        final ca = Computed((watch) {
          logs.add('a');
          return watch(a) * 2;
        });

        final cb = Computed((watch) {
          logs.add('b');
          return watch(b) * 2;
        });

        late BuildContext ctx;

        final builder = Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        });

        final bWidget = Builder(builder: (context) {
          context.watch(cb);
          return builder;
        });

        final aWidget = Builder(builder: (context) {
          context.watch(ca);
          return bWidget;
        });

        await tester.pumpWidget(
          BinderScope(
            // We override the states because we want them to be stored right now.
            overrides: [
              a.overrideWith(1),
              b.overrideWith(3),
            ],
            child: aWidget,
          ),
        );

        expect(ctx.read(a), 1);
        expect(ctx.read(b), 3);

        expect(logs, ['a', 'b']);

        ctx.write(a, 4);
        await tester.pump();

        // The `a` selector is runned twice before the rebuild of the widget
        // because we run it for the old state and the new one.
        expect(logs, ['a', 'b', 'a', 'a', 'a']);
      });

      testWidgets('can be used conditionnaly', (tester) async {
        final a = StateRef(1);
        final b = StateRef(2);
        final c = StateRef<StateRef<int>?>(a);

        int? state;
        int buildCount = 0;

        late BuildContext ctx;

        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (context) {
                ctx = context;
                buildCount++;

                final ref = context.watch(c);
                state = ref == null ? 0 : context.watch(ref);

                return const SizedBox();
              },
            ),
          ),
        );

        expect(state, 1);
        expect(buildCount, 1);
        ctx.write(a, 2);

        await tester.pump();
        expect(state, 2);
        expect(buildCount, 2);

        // We don't watch b currently.
        ctx.write(b, 3);
        await tester.pump();
        expect(state, 2);
        expect(buildCount, 2);

        // We change what we watch.
        ctx.write(c, b);
        await tester.pump();
        expect(state, 3);
        expect(buildCount, 3);

        // We don't watch a anymore.
        ctx.write(a, 9);

        await tester.pump();
        expect(state, 3);
        expect(buildCount, 3);

        // We change what we watch again.
        ctx.write(c, null);
        await tester.pump();
        expect(state, 0);
        expect(buildCount, 4);

        // We don't watch a or b anymore.
        ctx.write(a, 8);
        ctx.write(b, 7);
        await tester.pump();
        expect(state, 0);
        expect(buildCount, 4);
      });
    });

    group('overrides', () {
      testWidgets('- states are direclty saved', (tester) async {
        final intRef = StateRef(4);
        late BuildContext c0;
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

        final state = c0.findAncestorStateOfType<BinderScopeState>()!;
        expect(state.states.containsKey(intRef.key), true);
        expect(c0.read(intRef), 5);
      });

      testWidgets('are scoped to scope', (tester) async {
        final intRef = StateRef(4);
        late BuildContext c0;
        late BuildContext c1;
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
        late BuildContext ctx;

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
          late BuildContext ctx;

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
        late BuildContext ctx;

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
              .findAncestorStateOfType<BinderScopeState>()!
              .states
              .containsKey(a.key),
          isFalse,
        );
      });

      testWidgets('- new overrides are added', (tester) async {
        final a = StateRef(0);
        final b = StateRef(0);
        late BuildContext ctx;

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

      testWidgets('- states are updated when the initial value changes',
          (tester) async {
        final a = StateRef(0);
        final b = StateRef(0);

        late BuildContext ctx;
        int? result;

        final child = Builder(
          builder: (context) {
            result = context.watch(b);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          BinderScope(
            child: Builder(
              builder: (context) {
                ctx = context;
                return BinderScope(
                  overrides: [b.overrideWith(context.watch(a) + 4)],
                  child: child,
                );
              },
            ),
          ),
        );

        expect(result, 4);

        ctx.write(a, 8);
        await tester.pump();
        expect(result, 12);
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
        late BuildContext c0;

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

    testWidgets('modify a state ref through a child scope', (tester) async {
      final a = StateRef(1);

      late BuildContext ctx;
      int buildCount = 0;
      int buildCount2 = 0;
      int? value;
      int? value2;

      final w2 = Builder(
        builder: (context) {
          ctx = context;
          value2 = context.watch(a);
          buildCount2++;
          return const SizedBox();
        },
      );

      final w1 = Builder(
        builder: (context) {
          value = context.watch(a);
          buildCount++;
          return BinderScope(child: w2);
        },
      );

      await tester.pumpWidget(
        BinderScope(
          child: w1,
        ),
      );

      expect(buildCount, 1);
      expect(value, 1);
      expect(buildCount2, 1);
      expect(value2, 1);

      ctx.write(a, 2);
      await tester.pump();

      expect(buildCount, 2);
      expect(value, 2);
      expect(buildCount2, 2);
      expect(value2, 2);
    });

    testWidgets('watch a computed through two child scope', (tester) async {
      final a01 = StateRef(1);
      final a02 = StateRef(2);
      final b = StateRef(StateRef(0));
      final c = Computed((watch) {
        return watch(watch(b)) + 1;
      });

      late BuildContext ctx;
      int? value01;
      int? value02;

      final wc01 = Builder(
        builder: (context) {
          value01 = context.watch(c);
          return const SizedBox();
        },
      );

      final wc02 = Builder(
        builder: (context) {
          value02 = context.watch(c);
          return const SizedBox();
        },
      );

      final wcontext = Builder(
        builder: (context) {
          ctx = context;
          return const SizedBox();
        },
      );

      final wb = Column(
        children: [
          BinderScope(
            overrides: [b.overrideWith(a01)],
            child: wc01,
          ),
          BinderScope(
            overrides: [b.overrideWith(a02)],
            child: wc02,
          ),
          wcontext,
        ],
      );

      final w = Builder(
        builder: (context) {
          return wb;
        },
      );

      await tester.pumpWidget(BinderScope(child: w));

      expect(value01, 2);
      expect(value02, 3);

      ctx.write(a01, 4);
      await tester.pump();

      expect(value01, 5);
      expect(value02, 3);
    });
  });
}
