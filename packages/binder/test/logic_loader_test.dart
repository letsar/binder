import 'dart:async';

import 'package:binder/binder.dart';
import 'package:binder/src/core.dart';
import 'package:binder/src/logic_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: avoid_redundant_argument_values

class MyLogic implements Loadable {
  MyLogic();

  final Completer<void> completer = Completer<void>();

  @override
  Future<void> load() {
    return completer.future;
  }
}

void main() {
  group('LogicLoader', () {
    test('constructor assertions', () {
      expect(
        () => LogicLoader(
          refs: null,
          builder: (a, b, c) => c,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );

      expect(
        () => LogicLoader(
          refs: const [],
          builder: null,
          child: null,
        ),
        throwsAssertionError,
      );

      const LogicLoader(
        refs: [],
        builder: null,
        child: SizedBox(),
      );

      LogicLoader(
        refs: const [],
        builder: (a, b, c) => c,
        child: null,
      );
    });

    testWidgets('child is not rebuilt when load finishes.', (tester) async {
      final logic = MyLogic();
      final logicRef = LogicRef((scope) => logic);
      int buildCount = 0;

      await tester.pumpWidget(
        BinderScope(
          child: LogicLoader(
            refs: [logicRef],
            child: Builder(
              builder: (context) {
                buildCount++;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);
      logic.completer.complete();
      expect(buildCount, 1);
      await tester.pumpAndSettle();
      expect(buildCount, 1);
    });

    testWidgets('builder builds the child if any.', (tester) async {
      int buildCount = 0;
      final widget = Builder(
        builder: (context) {
          buildCount++;
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        BinderScope(
          child: LogicLoader(
            refs: const [],
            builder: (context, loading, child) {
              expect(child, widget);
              return child;
            },
            child: widget,
          ),
        ),
      );

      expect(buildCount, 1);
    });

    testWidgets('builder can have a null child', (tester) async {
      Widget widget;

      await tester.pumpWidget(
        BinderScope(
          child: LogicLoader(
            refs: const [],
            builder: (context, loading, child) {
              widget = child;
              return const SizedBox();
            },
            child: null,
          ),
        ),
      );

      expect(widget, null);
    });

    testWidgets('builder rebuilds when loading is done.', (tester) async {
      final logic = MyLogic();
      final logicRef = LogicRef((scope) => logic);
      int buildCount = 0;
      bool isLoading;

      await tester.pumpWidget(
        BinderScope(
          child: LogicLoader(
            refs: [logicRef],
            builder: (context, loading, child) {
              buildCount++;
              isLoading = loading;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(isLoading, true);
      logic.completer.complete();
      expect(buildCount, 1);
      expect(isLoading, true);

      await tester.pump();
      await tester.pump();
      expect(buildCount, 2);
      expect(isLoading, false);
    });

    testWidgets('builder waits for all loading to be done before rebuilding',
        (tester) async {
      final logic01 = MyLogic();
      final logic01Ref = LogicRef((scope) => logic01);

      final logic02 = MyLogic();
      final logic02Ref = LogicRef((scope) => logic02);
      int buildCount = 0;
      bool isLoading;

      await tester.pumpWidget(
        BinderScope(
          child: LogicLoader(
            refs: [logic01Ref, logic02Ref],
            builder: (context, loading, child) {
              buildCount++;
              isLoading = loading;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(isLoading, true);
      logic01.completer.complete();
      await tester.pump();
      await tester.pump();
      expect(buildCount, 1);
      expect(isLoading, true);
      logic02.completer.complete();
      await tester.pump();
      await tester.pump();
      expect(buildCount, 2);
      expect(isLoading, false);
    });
  });
}
