import 'package:binder/src/build_context_extensions.dart';
import 'package:binder/src/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('watch state ref through another one', (tester) async {
    final a = StateRef(1);
    final b = StateRef(StateRef(0));

    BuildContext ctx;
    int buildCount = 0;
    int value;

    final widget = Builder(
      builder: (context) {
        final ref = context.watch(b);
        value = context.watch(ref);
        buildCount++;
        ctx = context;
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      BinderScope(
        overrides: [
          b.overrideWith(a),
        ],
        child: widget,
      ),
    );

    expect(buildCount, 1);
    expect(value, 1);

    ctx.write(a, 5);
    await tester.pump();

    expect(buildCount, 2);
    expect(value, 5);
  });

  testWidgets('watch computed ref through a state ref of state ref',
      (tester) async {
    final a = StateRef(1);
    final b = StateRef(StateRef(0));
    final c = Computed((watch) {
      final value = watch(watch(b));
      return value + 6;
    });

    BuildContext ctx;
    int buildCount = 0;
    int value;

    final widget = Builder(
      builder: (context) {
        value = context.watch(c);
        buildCount++;
        ctx = context;
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      BinderScope(
        overrides: [
          b.overrideWith(a),
        ],
        child: widget,
      ),
    );

    expect(buildCount, 1);
    expect(value, 7);

    ctx.write(a, 5);
    await tester.pump();

    expect(buildCount, 2);
    expect(value, 11);
  });

  testWidgets('watch computed of multiple values', (tester) async {
    final a1 = StateRef(1);
    final a2 = StateRef(2);
    final a3 = StateRef(3);
    final a4 = StateRef(4);
    final c = Computed((watch) {
      final value = watch(a1) + watch(a2) + watch(a3) + watch(a4);
      return value.toInt();
    });

    BuildContext ctx;
    int buildCount = 0;
    int value;

    final widget = Builder(
      builder: (context) {
        value = context.watch(c);
        buildCount++;
        ctx = context;
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      BinderScope(
        child: widget,
      ),
    );

    expect(buildCount, 1);
    expect(value, 10);

    ctx.write(a1, 8);
    await tester.pump();

    expect(buildCount, 2);
    expect(value, 17);
  });

  testWidgets('watch computed of computed of multiple values', (tester) async {
    final a1 = StateRef(1);
    final a2 = StateRef(2);
    final a3 = StateRef(3);
    final a4 = StateRef(4);
    final c = Computed((watch) {
      final value = watch(a1) + watch(a2) + watch(a3) + watch(a4);
      return value.toInt();
    });

    final d1 = Computed((watch) {
      final value = watch(c);
      return value < 20;
    });

    final d2 = Computed((watch) {
      final value = watch(c);
      return value > 20;
    });

    BuildContext ctx;
    int buildCount = 0;
    int value;
    bool d1Value;
    bool d2Value;

    final widget = Builder(
      builder: (context) {
        value = context.watch(c);
        buildCount++;
        ctx = context;
        return const SizedBox();
      },
    );

    final widgetD1 = Builder(
      builder: (context) {
        d1Value = context.watch(d1);
        return const SizedBox();
      },
    );

    final widgetD2 = Builder(
      builder: (context) {
        d2Value = context.watch(d2);
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      BinderScope(
        child: Column(children: [widget, widgetD1, widgetD2]),
      ),
    );

    expect(buildCount, 1);
    expect(value, 10);
    expect(d1Value, true);
    expect(d2Value, false);

    ctx.write(a1, 11);
    await tester.pump();

    expect(buildCount, 2);
    expect(value, 20);
    expect(d1Value, false);
    expect(d2Value, false);

    ctx.write(a1, 12);
    await tester.pump();

    expect(buildCount, 3);
    expect(value, 21);
    expect(d1Value, false);
    expect(d2Value, true);
  });

  testWidgets('modify a state ref though a child scope', (tester) async {
    final a = StateRef(1);

    BuildContext ctx;
    int buildCount = 0;
    int value;

    final w2 = Builder(
      builder: (context) {
        ctx = context;
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

    ctx.write(a, 2);
    await tester.pump();

    expect(buildCount, 2);
    expect(value, 2);
  });
}
