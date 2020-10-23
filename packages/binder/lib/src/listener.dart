import 'package:flutter/widgets.dart';

import 'build_context_extensions.dart';
import 'core.dart';

typedef OnStateChanged<T> = void Function(BuildContext context, T state);

/// A widget which watches a [StateRef] and calls a function when
/// the underlying state changes.
class StateListener<T, S> extends StatelessWidget {
  /// Creates a [StateListener].
  ///
  /// The parameters [watchable], [onStateChanged] and [child] must not be null.
  const StateListener({
    Key key,
    @required this.watchable,
    @required this.onStateChanged,
    @required this.child,
  })  : assert(watchable != null),
        assert(onStateChanged != null),
        assert(child != null),
        super(key: key);

  /// The reference to watch.
  final Watchable<T, S> watchable;

  /// The function called when the state referenced changed.
  final OnStateChanged<S> onStateChanged;

  /// The widget below in the tree.
  ///
  /// {@macro flutter.widgets.child}.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final S value = context.watch(watchable);
    return ValueListener<S>(
      value: value,
      onValueChanged: onStateChanged,
      equalityComparer: watchable.equalityComparer,
      child: child,
    );
  }
}

bool _defaultEqualityComparer<T>(T previous, T current) => previous == current;

/// A widget that watches a value and calls a function when it changed.
class ValueListener<T> extends StatefulWidget {
  /// Creates a [ValueListener].
  ///
  /// The parameters [onValueChanged] and [child] must not be null.
  const ValueListener({
    Key key,
    @required this.value,
    @required this.onValueChanged,
    EqualityComparer<T> equalityComparer,
    @required this.child,
  })  : assert(onValueChanged != null),
        assert(child != null),
        equalityComparer = equalityComparer ?? _defaultEqualityComparer,
        super(key: key);

  /// The value to listen to changes.
  final T value;

  /// The function called when the [value] changed.
  final OnStateChanged<T> onValueChanged;

  /// The comparer used to know if the old and new value are equals.
  final EqualityComparer<T> equalityComparer;

  /// The widget below in the tree.
  ///
  /// {@macro flutter.widgets.child}.
  final Widget child;

  @override
  _ValueListenerState<T> createState() => _ValueListenerState<T>();
}

class _ValueListenerState<T> extends State<ValueListener<T>> {
  @override
  void didUpdateWidget(ValueListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.equalityComparer(oldWidget.value, widget.value)) {
      Future.microtask(() => widget.onValueChanged(context, widget.value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
