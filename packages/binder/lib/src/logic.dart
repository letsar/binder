import 'package:meta/meta.dart';

import 'core.dart';

/// Implements utilities methods for accessing the scope where this logic is
/// stored.
mixin Logic {
  /// The scope where this logic is stored.
  @visibleForOverriding
  Scope get scope;

  /// {@macro binder.scope.write}
  @protected
  @nonVirtual
  void write<T>(StateRef<T> ref, T state, [Object? action]) {
    scope.write(ref, state, action);
  }

  /// Updates the value of the state referenced by [ref] with a function which
  /// provides the current state.
  ///
  /// An optional [action] can be send to track which method did the update.
  @protected
  @nonVirtual
  void update<T>(StateRef<T> ref, Updater<T> updater, [Object? action]) {
    scope.write(ref, updater(scope.read(ref, null)), action);
  }

  /// {@macro binder.scope.clear}
  @protected
  @nonVirtual
  void clear<T>(StateRef<T> ref) {
    scope.clear(ref);
  }

  /// {@macro binder.scope.read}
  @protected
  @nonVirtual
  T read<T>(Watchable<T> ref) {
    return scope.read(ref, null);
  }

  /// {@macro binder.scope.use}
  @protected
  @nonVirtual
  T use<T>(LogicRef<T> ref) {
    return scope.use(ref);
  }

  /// {@macro binder.scope.undo}
  @nonVirtual
  void undo() => scope.undo();

  /// {@macro binder.scope.redo}
  @nonVirtual
  void redo() => scope.redo();
}
