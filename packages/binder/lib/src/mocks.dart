part of 'core.dart';

/// A mock designed for use when testing code that uses [Scope].
class MockScope implements Scope {
  final Map<BinderKey, Object?> _states = <BinderKey, Object?>{};
  final MementoObserver _mementoObserver = MementoObserver();

  /// Called when [clear] is called.
  void Function<T>(StateRef<T> ref)? onClear;

  /// Called when [read] is called.
  void Function<T>(Watchable<T> ref)? onRead;

  /// Called when [redo] is called.
  VoidCallback? onRedo;

  /// Called when [undo] is called.
  VoidCallback? onUndo;

  /// Called when [use] is called.
  void Function<T>(LogicRef<T> ref)? onUse;

  /// Called when [write] is called.
  void Function<T>(StateRef<T> ref, T state, Object? action)? onWrite;

  @override
  void clear<T>(StateRef<T> ref) {
    onClear?.call(ref);
    _states.remove(ref.key);
  }

  @override
  T read<T>(Watchable<T> ref, List<BinderKey>? keys) {
    onRead?.call(ref);
    return ref.read(_fetch, keys);
  }

  @override
  void redo() {
    onRedo?.call();
    _mementoObserver.redo(this);
  }

  @override
  void undo() {
    onUndo?.call();
    _mementoObserver.undo(this);
  }

  @override
  T use<T>(LogicRef<T> ref) {
    onUse?.call(ref);
    return _states.putIfAbsent(ref.key, () => ref.create(this)) as T;
  }

  @override
  void write<T>(StateRef<T> ref, T state, [Object? action]) {
    onWrite?.call(ref, state, action);
    final T oldState =
        _states.containsKey(ref.key) ? _states[ref.key] as T : ref.initialState;
    _states[ref.key] = state;
    _mementoObserver.didChanged(ref, oldState, state, action);
  }

  /// Clears all the states.
  void reset() {
    _states.clear();
    _mementoObserver.clear();
    onClear = null;
    onRead = null;
    onRedo = null;
    onUndo = null;
    onUse = null;
    onWrite = null;
  }

  T _fetch<T>(BinderKey key, T defaultState) {
    if (_states.containsKey(key)) {
      return _states[key] as T;
    } else {
      return defaultState;
    }
  }
}
