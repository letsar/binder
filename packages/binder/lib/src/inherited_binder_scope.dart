part of 'core.dart';

class InheritedBinderScope extends InheritedModel<Aspect> {
  const InheritedBinderScope({
    Key key,
    @required this.container,
    @required this.scope,
    @required Widget child,
  })  : assert(container != null),
        assert(child != null),
        super(key: key, child: child);

  final BinderContainer container;
  final Scope scope;

  @override
  bool updateShouldNotify(InheritedBinderScope oldWidget) {
    return oldWidget.container != container;
  }

  @override
  bool updateShouldNotifyDependent(
    InheritedBinderScope oldWidget,
    Set<Aspect> dependencies,
  ) {
    final oldReader = oldWidget.container.fetch;
    final newReader = container.fetch;

    return dependencies.any((aspect) {
      return aspect.shouldRebuild(oldReader, newReader);
    });
  }

  static InheritedBinderScope of(BuildContext context, [Aspect aspect]) {
    return InheritedModel.inheritFrom<InheritedBinderScope>(
      context,
      aspect: aspect,
    );
  }
}

@immutable
@visibleForTesting
class Aspect<T, S> {
  const Aspect(this.ref);
  final Watchable<T, S> ref;

  bool shouldRebuild(StateReader oldReader, StateReader newReader) {
    final S oldState = ref.read(oldReader);
    final S newState = ref.read(newReader);
    final bool result = !ref.equals(oldState, newState);
    return result;
  }
}
