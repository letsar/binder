import 'package:flutter/widgets.dart';

import 'build_context_extensions.dart';
import 'core.dart';

/// Interface for business logic components that can be used with [LogicLoader].
abstract class Loadable {
  /// Loads data.
  Future<void> load();
}

/// Signature for a function that builds a widget given the [loading] state.
///
/// Used by [LogicLoader.builder].
typedef LoadableWidgetBuilder = Widget Function(
  BuildContext context,
  bool loading,
  Widget? child,
);

/// A widget which can be used to load resources when it's inserted in the tree.
///
/// For example, you can use this widget to load data from the repository, the
/// first time this widget builds.
class LogicLoader extends StatefulWidget {
  /// Creates a [LogicLoader] which will call the [Loadable.load] method of all
  /// the [LogicRef]s of the given [refs], when it's inserted in the tree.
  ///
  /// [refs] must not be null.
  /// [child] and [builder] must not be both null.
  ///
  /// If [builder] is set, [child] can be used as a subtree that does not
  /// depends on the loading argument.
  const LogicLoader({
    Key? key,
    this.refs = const <LogicRef<Loadable>>[],
    this.builder,
    this.child,
  })  : assert(
          child != null || builder != null,
          'Either child or builder must be not null',
        ),
        super(key: key);

  /// Logic references that needs to be loaded when this widget is inserted in
  /// the tree.
  final List<LogicRef<Loadable>> refs;

  /// The builder that creates a child to display in this widget, which will
  /// use the provided loading state to show whether data is being fetched.
  final LoadableWidgetBuilder? builder;

  /// The widget to pass to [builder] if it's not null, or the child to
  /// directly display in this widget.
  final Widget? child;

  @override
  _LogicLoaderState createState() => _LogicLoaderState();
}

class _LogicLoaderState extends State<LogicLoader> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // We delay the loading, because if one of the `load` method is calling
    // `write` synchronously, we would end up with an error, because we can't
    // rebuild a parent here.
    // The counter part, is that the actual rebuild will occur in two frames
    // and not in the next one.
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    final futures = widget.refs.map((ref) => context.use(ref).load());
    try {
      await Future.wait(futures);
    } finally {
      if (widget.builder != null) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    if (builder != null) {
      return builder(context, loading, widget.child);
    }

    return widget.child!;
  }
}
