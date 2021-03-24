import 'package:binder/src/core.dart';
import 'package:binder/src/logic.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unrelated_type_equality_checks

class MyLogic with Logic {
  const MyLogic(this.scope);

  @override
  final Scope scope;
}

class MockLogic extends Mock with Logic implements Disposable {}

final mockScope = MockScope();
final myLogic = MyLogic(mockScope);
final stateRef = StateRef(0, name: 'my_state_ref');
final logicRef = LogicRef((scope) => null);

void main() {
  setUp(() {
    mockScope.reset();
  });

  group('Logic', () {
    test('clear calls binder.clear', () {
      final logs = <String>[];
      mockScope.onClear = <T>(ref) => logs.add('clear ${ref.key.name}');
      myLogic.clear(stateRef);
      expect(logs, ['clear my_state_ref']);
    });

    test('read calls binder.read', () {
      final logs = <bool>[];

      mockScope.onRead = <T>(watchable) => logs.add(watchable == stateRef);
      myLogic.read(stateRef);
      expect(logs, [true]);
      logs.clear();

      final selector = stateRef.select((state) => state + 3);
      mockScope.onRead = <T>(watchable) => logs.add(watchable == selector);
      myLogic.read(selector);
      expect(logs, [true]);
      logs.clear();

      final computed = Computed((watch) => watch(stateRef) + 3);
      mockScope.onRead = <T>(watchable) => logs.add(watchable == computed);
      myLogic.read(computed);
      expect(logs, [true]);
    });

    test('redo calls binder.redo', () {
      var called = false;
      mockScope.onRedo = () => called = true;
      myLogic.redo();
      expect(called, true);
    });

    test('undo calls binder.undo', () {
      var called = false;
      mockScope.onUndo = () => called = true;
      myLogic.undo();
      expect(called, true);
    });

    test('update calls binder.write with expected arguments', () {
      final logs = <String>[];
      mockScope.onWrite = <T>(ref, state, action) => logs.add('$action $state');
      int updateStateRef(int state) => state + 5;

      myLogic.update(stateRef, updateStateRef, 'action');
      expect(mockScope.read(stateRef, null), 5);
      expect(logs, ['action 5']);
    });

    test('use calls binder.use', () {
      var called = false;
      mockScope.onUse = <T>(_) => called = true;
      myLogic.use(logicRef);
      expect(called, true);
    });

    test('write calls binder.write', () {
      final logs = <String>[];
      mockScope.onWrite = <T>(ref, state, action) {
        logs.add('${ref.key.name} $state');
      };
      myLogic.write(stateRef, 8);
      expect(logs, ['my_state_ref 8']);
    });

    testWidgets('dispose called after BinderScope disposed', (tester) async {
      final mockLogic = MockLogic();
      final a = LogicRef((scope) => mockLogic);
      await tester.pumpWidget(
        BinderScope(
          overrides: [a.overrideWithSelf()],
          child: const SizedBox(),
        ),
      );

      await tester.pumpWidget(const SizedBox());

      verify(() => mockLogic.dispose());
    });
  });
}
