part of 'core.dart';

/// Internal use.
final mementoRef = StateRef<MementoObserver>(null);

/// A scope where state chances a watched so that they can be undone/redone.
class MementoScope extends StatefulWidget {
  /// Creates a scope under which you can use undo/redo methods.
  ///
  /// The parameters [maxCapacity], [refs] and [child] must no be null.
  const MementoScope({
    Key key,
    this.maxCapacity = 256,
    this.refs = const [],
    @required this.child,
  })  : assert(maxCapacity != null),
        assert(child != null),
        assert(refs != null),
        super(key: key);

  /// The maximum number of changes watched by this scope.
  /// Defaults to 256.
  final int maxCapacity;

  /// The references where changes have to be observed.
  /// If empty, all the referenced are observed.
  final List<StateRef> refs;

  /// The subtree where undo/redo methods can be used.
  final Widget child;

  @override
  _MementoScopeState createState() => _MementoScopeState();
}

class _MementoScopeState extends State<MementoScope> {
  MementoObserver memento;

  @override
  void initState() {
    super.initState();
    memento = MementoObserver(
      maxCapacity: widget.maxCapacity,
      keys: widget.refs.map((e) => e.key).toSet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BinderScope(
      overrides: [mementoRef.overrideWith(memento)],
      observers: [memento],
      child: widget.child,
    );
  }
}

class MementoObserver implements StateObserver {
  MementoObserver({
    int maxCapacity = 256,
    this.keys,
  })  : _undoStack = EvictingQueue<_Variation>(maxCapacity),
        _redoStack = EvictingQueue<_Variation>(maxCapacity);

  final EvictingQueue<_Variation> _undoStack;
  final EvictingQueue<_Variation> _redoStack;
  final Set<BinderKey> keys;

  void undo(Scope scope) {
    if (_undoStack.isNotEmpty) {
      final _Variation variation = _undoStack.dequeue();
      _redoStack.enqueue(variation);
      variation.undo(scope);
    }
  }

  void redo(Scope scope) {
    if (_redoStack.isNotEmpty) {
      final _Variation variation = _redoStack.dequeue();
      _undoStack.enqueue(variation);
      variation.redo(scope);
    }
  }

  @override
  bool didChanged<X>(StateRef<X> ref, X oldState, X newState, Object action) {
    if (action is! MementoAction && (keys.isEmpty || keys.contains(ref.key))) {
      _undoStack.enqueue(_Variation<X>(ref, oldState, newState, action));
      _redoStack.clear();
    }
    return false;
  }
}

class _Variation<T> {
  const _Variation(this.ref, this.oldState, this.newState, this.action);

  final StateRef<T> ref;
  final T oldState;
  final T newState;
  final Object action;

  void undo(Scope scope) {
    scope.write(ref, oldState, UndoAction(action));
  }

  void redo(Scope scope) {
    scope.write(ref, newState, RedoAction(action));
  }
}

/// The action wrapping the action to undo or redo.
abstract class MementoAction {
  const MementoAction._(
    this._name,
    Object action,
  ) : action = action ?? '';

  final String _name;

  /// The wrapped action.
  final Object action;

  @override
  String toString() {
    return '$_name $action';
  }
}

/// The action wrapping the action to undo.
class UndoAction extends MementoAction {
  @visibleForTesting
  const UndoAction(Object action) : super._('undo', action);
}

/// The action wrapping the action to redo.
class RedoAction extends MementoAction {
  @visibleForTesting
  const RedoAction(Object action) : super._('redo', action);
}

/// A queue which have a predetermined maximum capacity. The oldest element is
/// replaced when the full capacity is reached.
class EvictingQueue<T> {
  /// Creates a queue with the specified [maxCapacity].
  EvictingQueue([this.maxCapacity = _defaultMaxCapacity])
      : assert(maxCapacity != null && maxCapacity > 0),
        _items = <T>[],
        _tail = 0;

  static const int _defaultMaxCapacity = 8;

  /// The total number of elements this queue can hold.
  final int maxCapacity;

  final List<T> _items;

  int _tail;

  /// The number of items.
  int get length => _items.length;

  /// Returns `true` if there is at least one item.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Adds an item at the tail.
  ///
  /// If full capacity of this queue is reached, then the oldest item is
  /// replaced.
  void enqueue(T item) {
    if (length == maxCapacity) {
      // We evict the oldest element.
      _tail = (_tail + 1) % maxCapacity;
      _items[_tail] = item;
    } else {
      // We add a new item.
      _tail = length;
      _items.add(item);
    }
  }

  /// Removes the item at the tail.
  ///
  /// The queue must not be empty when this method is called.
  T dequeue() {
    final T item = _items.removeAt(_tail);
    _tail = (_tail - 1) % maxCapacity;
    return item;
  }

  /// Removes all the items.
  void clear() {
    _items.clear();
    _tail = 0;
  }
}
