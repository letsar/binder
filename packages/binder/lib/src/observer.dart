import 'core.dart';

typedef OnStateUpdated = bool Function<T>(
  StateRef<T> ref,
  T oldState,
  T newState,
  Object action,
);

/// An object that observes state changes.
///
/// If there are multiple [BinderScope]s. All Observers between the logic and
/// the scope where the state is saved, are called.
///
/// For example, in the following snippet, observers b and a, are called when
/// the logic l updates changes.
///
/// ```dart
/// BinderScope(
///   observers: [a],
///   child: BinderScope(
///     overrides: [l.overrideWithSelf()],
///     observers: [b],
///   ),
/// );
/// ```
abstract class StateObserver {
  /// Called when a state changed.
  /// This method must return [true] if the changes have been handled and other
  /// observers must no be called, or [false] if other observers can be called.
  bool didChanged<T>(StateRef<T> ref, T oldState, T newState, Object action);
}

/// A specific [StateObserver] which delegates the actual implementation to a
/// function.
class DelegatingStateObserver implements StateObserver {
  /// Creates a [DelegatingStateObserver].
  const DelegatingStateObserver(this.onStateUpdated);

  /// The function called when a state changed.
  final OnStateUpdated onStateUpdated;

  @override
  bool didChanged<T>(StateRef<T> ref, T oldState, T newState, Object action) {
    return onStateUpdated(ref, oldState, newState, action);
  }
}
