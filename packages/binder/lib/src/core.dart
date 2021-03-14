library core;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'binder_container.dart';

part 'binder_scope.dart';
part 'inherited_binder_scope.dart';
part 'memento.dart';
part 'observer.dart';

/// Signature for determining whether two states are the same.
typedef EqualityComparer<T> = bool Function(T a, T b);

/// Signature for selecting a part of a [state].
typedef Selector<T, S> = S Function(T state);

/// Signature for updating a state.
typedef Updater<T> = T Function(T oldState);

/// Signature for creating a derived state from other states.
///
/// Used by [Computed].
typedef StateWatcher = T Function<T>(Watchable<T> ref);

/// Signature for creating a derived state from other states on demand.
///
/// Used by [Computed].
typedef StateBuilder<T> = T Function(StateWatcher watch);

/// Internal use only.
typedef StateReader = T Function<T>(BinderKey key, T defaultState);

/// Signature for creating an object from a [binder].
typedef InstanceFactory<T> = T Function(Scope scope);

/// An object which holds a part of the application state.
abstract class Scope {
  /// {@template binder.scope.write}
  /// Updates the value of the state referenced by [ref] with [state].
  ///
  /// An optional [action] can be send to track which method did the update.
  /// {@endtemplate}
  void write<T>(StateRef<T> ref, T state, [Object action]);

  /// {@template binder.scope.clear}
  /// Removes the state referenced by [ref] from the scope.
  /// {@endtemplate}
  void clear<T>(StateRef<T> ref);

  /// {@template binder.scope.read}
  /// Gets the current state referenced by [ref].
  /// {@endtemplate}
  T read<T>(Watchable<T> ref, List<BinderKey> keys);

  /// {@template binder.scope.use}
  /// Gets the current logic component referenced by [ref].
  /// {@endtemplate}
  T use<T>(LogicRef<T> ref);

  /// {@template binder.scope.undo}
  /// Cancels the last write.
  /// {@endtemplate}
  void undo();

  /// {@template binder.scope.redo}
  /// Re-executes a previously canceled write.
  /// {@endtemplate}
  void redo();
}

/// A part of the app state that can be watched.
@immutable
abstract class Watchable<T> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const Watchable(this.equalityComparer);

  /// The predicate determining if two states are the same.
  final EqualityComparer<T> equalityComparer;

  /// Internal use only.
  bool equals(T oldState, T newState) =>
      _equals(equalityComparer, oldState, newState);

  /// Internal use only.
  @visibleForTesting
  T read(StateReader read, List<BinderKey> keys);
}

/// A reference to a part of the app state.
class StateRef<T> extends Watchable<T> {
  /// Creates a reference to a part of the app state with an [initialState].
  ///
  /// An [equalityComparer] can be provided to determine whether two instances
  /// are the same.
  ///
  /// A [name] can be provided to this reference for debugging purposes.
  StateRef(
    T initialState, {
    EqualityComparer<T> equalityComparer,
    String name,
  }) : this._(
          initialState,
          equalityComparer,
          BinderKey(name ?? 'StateRef<$T>'),
        );

  const StateRef._(
    this.initialState,
    EqualityComparer<T> equalityComparer,
    this.key,
  ) : super(equalityComparer);

  /// This is the initial value of the state.
  final T initialState;

  /// Internal use.
  final BinderKey key;

  /// Overrides this referenced with a new value.
  ///
  /// Useful for subtrees with different values under the same reference.
  BinderOverride<T> overrideWith(T state) {
    return BinderOverride<T>._(key, (scope) => state);
  }

  @override
  T read(StateReader read, List<BinderKey> keys) {
    keys?.add(key);
    return read<T>(key, initialState);
  }
}

/// A watchable derived state.
class Computed<T> extends Watchable<T> {
  /// Creates a derived state which combine the current state of other parts and
  /// allows any widget to be rebuilt when the underlaying value changes.
  const Computed(
    this.stateBuilder, {
    EqualityComparer<T> equalityComparer,
  }) : super(equalityComparer);

  /// The function used to build the state.
  final StateBuilder<T> stateBuilder;

  @override
  T read(StateReader read, List<BinderKey> keys) {
    X watch<X>(Watchable<X> p) {
      return p.read(read, keys);
    }

    return stateBuilder(watch);
  }
}

class StateSelector<T, S> extends Watchable<S> {
  const StateSelector(
    this.ref,
    this.selector,
    EqualityComparer<S> equalityComparer,
  ) : super(equalityComparer);

  final Watchable<T> ref;
  final Selector<T, S> selector;

  @override
  S read(StateReader read, List<BinderKey> keys) {
    return selector(ref.read(read, keys));
  }
}

/// Extensions for [Watchable].
extension WatchableExtensions<T> on Watchable<T> {
  /// Creates a selector on a reference that can be watched.
  Watchable<S> select<S>(
    Selector<T, S> selector, {
    EqualityComparer<S> equalityComparer,
  }) {
    return StateSelector(this, selector, equalityComparer);
  }
}

/// A redefinition of a [StateRef] or [LogicRef].
@immutable
class BinderOverride<T> {
  const BinderOverride._(this.key, this.create);

  /// Internal use.
  final BinderKey key;

  /// Internal use.
  final InstanceFactory<T> create;
}

/// A reference to a business logic component.
@immutable
class LogicRef<T> {
  /// Creates a reference to a business logic component.
  ///
  /// The [create] parameter must not be null and it's used to generate a
  /// logic component instance.
  ///
  /// A [name] can be provided to this reference for debugging purposes.
  LogicRef(
    this.create, {
    String name,
  })  : assert(create != null),
        key = BinderKey(name ?? 'LogicRef<$T>');

  /// The function used to generate an instance.
  final InstanceFactory<T> create;

  /// Internal use.
  final BinderKey key;

  /// Overrides the logic component with a new factory.
  /// This can be useful for mocking purposes.
  BinderOverride<T> overrideWith(InstanceFactory<T> create) {
    return BinderOverride<T>._(key, create);
  }

  /// Overrides the logic component with the same factory.
  /// This can be useful when we want to explicitely choose the scope where the
  /// logic is created.
  /// For example when we override a [StateRef] we also want to override any
  /// [LogicRef], which will use this [StateRef], under the same [BinderScope].
  BinderOverride<T> overrideWithSelf() {
    return BinderOverride<T>._(key, create);
  }
}

bool _equals<T>(EqualityComparer<T> equalityComparer, T oldState, T newState) {
  if (equalityComparer != null) {
    return equalityComparer(oldState, newState);
  } else {
    return const DeepCollectionEquality().equals(oldState, newState);
  }
}
