import 'package:binder/src/core.dart';
import 'package:binder/src/logic.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore_for_file: invalid_use_of_protected_member

class MockScope extends Mock implements Scope {}

class MyLogic with Logic {
  const MyLogic(this.scope);

  @override
  final Scope scope;
}

class MockLogic extends Mock with Logic implements Disposable {}

Scope mockScope;
MyLogic myLogic;
final stateRef = StateRef(0);
final logicRef = LogicRef((scope) => null);

void main() {
  setUp(() {
    mockScope = MockScope();
    myLogic = MyLogic(mockScope);
  });

  group('Logic', () {
    test('clear calls binder.clear', () {
      myLogic.clear(stateRef);
      verify(mockScope.clear(stateRef));
    });

    test('read calls binder.read', () {
      myLogic.read(stateRef);
      verify(mockScope.read(stateRef, null));

      final selector = stateRef.select((state) => state + 3);
      myLogic.read(selector);
      verify(mockScope.read(selector, null));

      final computed = Computed((watch) => watch(stateRef) + 3);
      myLogic.read(computed);
      verify(mockScope.read(computed, null));
    });

    test('redo calls binder.redo', () {
      myLogic.redo();
      verify(mockScope.redo());
    });

    test('undo calls binder.undo', () {
      myLogic.undo();
      verify(mockScope.undo());
    });

    test('update calls binder.write with expected arguments', () {
      when(mockScope.read(stateRef, null)).thenReturn(4);
      int updateStateRef(int state) => state + 1;

      myLogic.update(stateRef, updateStateRef, 'action');
      verify(mockScope.read(stateRef, null));
      verify(mockScope.write(stateRef, 5, 'action'));
    });

    test('use calls binder.use', () {
      myLogic.use(logicRef);
      verify(mockScope.use(logicRef));
    });

    test('write calls binder.write', () {
      myLogic.write(stateRef, 8);
      verify(mockScope.write(stateRef, 8));
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

      verify(mockLogic.dispose());
    });
  });
}
