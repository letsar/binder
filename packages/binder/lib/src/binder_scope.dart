part of 'core.dart';

/// A widget that stores a part of the app state.
///
/// Any Flutter application must have at least one [BinderScope].
/// The more convenient place is to have it at the root of the widget tree.
///
/// ```dart
/// void main() => runApp(BinderScope(child: MyApp()));
/// ```
class BinderScope extends StatefulWidget {
  /// Creates a [BinderScope].
  ///
  /// [overrides], [observers] and [child] must not be null.
  const BinderScope({
    Key key,
    this.overrides = const [],
    this.observers = const [],
    @required this.child,
  })  : assert(overrides != null),
        assert(observers != null),
        assert(child != null),
        super(key: key);

  /// List of objects that are redefining the meaning of refs.
  /// It can also be useful for test purposes.
  final List<BinderOverride> overrides;

  /// Objects that can observe state changes.
  final List<StateObserver> observers;

  /// The subtree that can use Binder for state management.
  final Widget child;

  @override
  BinderScopeState createState() => BinderScopeState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>(
      'overrides',
      overrides.map((x) => x.key.name),
    ));
    properties.add(IterableProperty<String>(
      'observers',
      observers.map((x) => describeIdentity(x)),
    ));
  }
}

@visibleForTesting
class BinderScopeState extends State<BinderScope>
    with BinderContainerMixin, AutomaticKeepAliveClientMixin<BinderScope>
    implements Scope {
  final Set<BinderKey> readOnlyKeys = <BinderKey>{};
  final Set<BinderKey> writtenKeys = <BinderKey>{};
  bool clearScheduled = false;

  @override
  BinderScopeState parent;

  @override
  Map<BinderKey, Object> states = <BinderKey, Object>{};

  @override
  void initState() {
    super.initState();
    widget.overrides.forEach((override) {
      addWrittenKey(override.key);
      states[override.key] = override.create(this);
      readOnlyKeys.add(override.key);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parent = InheritedBinderScope.of(context)?.scope as BinderScopeState;
  }

  @override
  void didUpdateWidget(BinderScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldOverrides = oldWidget.overrides;
    final newOverrides = widget.overrides;

    oldOverrides.forEach((oldOverride) {
      final key = oldOverride.key;
      final newOverride = newOverrides.firstWhere(
        (x) => x.key == key,
        orElse: () => null,
      );
      if (newOverride != null) {
        // We have to update the state only if the state has never been written.
        if (readOnlyKeys.contains(key)) {
          addWrittenKey(key);
          states[key] = newOverride.create(this);
        }
      } else {
        // We have to remove states from overrides that are no longer present.
        addWrittenKey(key);
        readOnlyKeys.remove(key);
        states.remove(key);
      }
    });

    // We have to add states from newly overrides.
    newOverrides.forEach((newOverride) {
      final key = newOverride.key;
      if (!oldOverrides.containsKey(key)) {
        readOnlyKeys.add(key);
        addWrittenKey(key);
        states[key] = newOverride.create(this);
      }
    });
  }

  @override
  void dispose() {
    states.values.whereType<Disposable>().forEach((state) => state.dispose());
    super.dispose();
  }

  /// Internal use only.
  @visibleForTesting
  BinderContainer createContainer() {
    return BinderContainer(states.clone(), parent?.createContainer());
  }

  @override
  void write<T>(StateRef<T> ref, T state, [Object action]) {
    writeAndObserve(ref, state, action, []);
  }

  void addWrittenKey(BinderKey key) {
    writtenKeys.add(key);
    if (!clearScheduled) {
      clearScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        clearScheduled = false;
        writtenKeys.clear();
      });
    }
  }

  /// Internal use only.
  @visibleForTesting
  void writeAndObserve<T>(
    StateRef<T> ref,
    T state,
    Object action,
    List<StateObserver> observers,
  ) {
    if (isOwner(ref.key)) {
      void applyNewState() {
        addWrittenKey(ref.key);
        readOnlyKeys.remove(ref.key);
        setState(() {
          states[ref.key] = state;
        });
      }

      final effectiveObservers = [...observers, ...widget.observers];

      if (effectiveObservers.isEmpty) {
        applyNewState();
      } else {
        final T oldState = states.containsKey(ref.key)
            ? states[ref.key] as T
            : ref.initialState;
        applyNewState();
        effectiveObservers.any((observer) {
          return observer.didChanged(ref, oldState, state, action);
        });
      }
    } else {
      parent.writeAndObserve(
        ref,
        state,
        action,
        [
          ...observers,
          ...widget.observers,
        ],
      );
    }
  }

  @override
  void clear<T>(StateRef<T> ref) {
    if (isOwner(ref.key)) {
      final key = ref.key;
      setState(() {
        addWrittenKey(key);
        readOnlyKeys.remove(key);
        states.remove(key);
      });
    } else {
      parent.clear(ref);
    }
  }

  @override
  T read<T>(Watchable<T> ref, List<BinderKey> keys) {
    return ref.read(fetch, keys);
  }

  @override
  T use<T>(LogicRef<T> ref) {
    if (isOwner(ref.key)) {
      return states.putIfAbsent(ref.key, () => ref.create(this)) as T;
    } else {
      return parent.use(ref);
    }
  }

  MementoObserver _readMemento() {
    final memento = read(mementoRef, null);
    assert(memento != null, 'There is no MementoScope above this context');
    return memento;
  }

  @override
  void undo() => _readMemento().undo(this);

  @override
  void redo() => _readMemento().redo(this);

  @override
  bool get wantKeepAlive => true;

  Set<BinderKey> get allWrittenKeys =>
      writtenKeys.toSet()..addAll(parent?.allWrittenKeys ?? {});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InheritedBinderScope(
      container: createContainer(),
      scope: this,
      writtenKeys: allWrittenKeys,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    states.forEach((key, state) {
      properties.add(DiagnosticsProperty(key.name, state));
    });
  }
}

/// Interface for business logic components that need to do some action before
/// the [BinderScope] storing their state is disposed.
abstract class Disposable {
  /// Release resources.
  void dispose();
}

extension on Map<BinderKey, Object> {
  Map<BinderKey, Object> clone() => Map<BinderKey, Object>.from(this);
}

extension on List<BinderOverride> {
  bool containsKey(BinderKey key) => any((x) => x.key == key);
}
