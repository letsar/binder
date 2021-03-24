import 'package:binder/src/binder_container.dart';
import 'package:flutter_test/flutter_test.dart';

const empty = <BinderKey, Object>{};

void main() {
  group('BinderContainer', () {
    test('isOwner returns true if there are no parent', () {
      const key = BinderKey('');
      const container = BinderContainer({key: 0}, null);
      final isContainer = container.isOwner(key);
      expect(isContainer, true);
    });

    test('isOwner returns true if the key exists', () {
      const key = BinderKey('');
      const parent = BinderContainer(<BinderKey, Object?>{}, null);
      const container = BinderContainer({key: 0}, parent);
      final isContainer = container.isOwner(key);
      expect(isContainer, true);
    });

    test(
        'isOwner returns false if the key does not exist and parent is not null',
        () {
      const key = BinderKey('');
      const parent = BinderContainer(<BinderKey, Object?>{}, null);
      const container = BinderContainer(empty, parent);
      final isContainer = container.isOwner(key);
      expect(isContainer, false);
    });

    test(
        'fetch returns the defaultState if the key does not exist and no parent',
        () {
      const key = BinderKey('');
      const container = BinderContainer(empty, null);
      final state = container.fetch(key, 42);
      expect(state, 42);
    });

    test('fetch returns the state if the key exists and no parent', () {
      const key = BinderKey('');
      const container = BinderContainer({key: 84}, null);
      final state = container.fetch(key, 42);
      expect(state, 84);
    });

    test('fetch returns the state of the parent if the key does not exist', () {
      const key = BinderKey('');

      const parent = BinderContainer({key: 84}, null);
      const container = BinderContainer(empty, parent);
      final state = container.fetch(key, 42);
      expect(state, 84);
    });

    test('fetch returns the defaultState if the key does not exist at all', () {
      const key = BinderKey('');

      const parent = BinderContainer(empty, null);
      const container = BinderContainer(empty, parent);
      final state = container.fetch(key, 42);
      expect(state, 42);
    });

    test('containers are different if states different and parents equals', () {
      const key = BinderKey('');

      const x = BinderContainer({key: 0}, null);
      const y = BinderContainer({key: 1}, null);
      expect(x == y, false);
      expect(x.hashCode == y.hashCode, isFalse);
    });

    test('containers are different if states equals and parents different', () {
      const key = BinderKey('');

      const x = BinderContainer({key: 0}, null);
      const y = BinderContainer({key: 0}, x);
      expect(x == y, false);
      expect(x.hashCode == y.hashCode, isFalse);
    });

    test('containers are equals if states equals and parents equals', () {
      const a = BinderContainer(empty, null);
      const x = BinderContainer(empty, a);
      const y = BinderContainer(empty, a);
      expect(x == y, true);
      expect(x.hashCode == y.hashCode, isTrue);
    });
  });
}
