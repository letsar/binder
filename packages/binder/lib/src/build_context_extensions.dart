import 'package:flutter/widgets.dart';

import 'binder_container.dart';
import 'core.dart';

// ignore_for_file: public_member_api_docs

/// Public extensions on [BuildContext].
extension BinderBuildContextExtensions on BuildContext {
  /// Reads the current state of [watchable] and rebuilds the widget calling
  /// this methods when the state changes.
  ///
  /// Cannot be called outside a build method.
  T watch<T>(Watchable<T> watchable) {
    assert(
        widget is LayoutBuilder ||
            widget is SliverWithKeepAliveWidget ||
            debugDoingBuild,
        'Cannot call watch() outside a build method.');
    final keys = <BinderKey>[];
    return watchScope(watchable, keys).read(watchable, keys);
  }

  /// Reads the current state of the [watchable].
  ///
  /// Cannot be called while building a widget.
  T read<T>(Watchable<T> watchable) {
    assert(!debugDoingBuild, 'Cannot call read() while building a widget.');
    return readScope().read(watchable, null);
  }

  /// Gets the instance of the business logic component referenced by [ref].
  ///
  /// Cannot be called while building a widget.
  T use<T>(LogicRef<T> ref) {
    assert(!debugDoingBuild, 'Cannot call use() while building a widget.');
    return readScope().use(ref);
  }
}

extension BinderBuildContextInternalExtensions on BuildContext {
  Scope readScope() {
    return getBinder(
      getElementForInheritedWidgetOfExactType<InheritedBinderScope>()?.widget
          as InheritedBinderScope?,
    );
  }

  Scope watchScope<T>(Watchable<T> ref, List<BinderKey> keys) {
    return getBinder(InheritedBinderScope.of(this, Aspect<T>(ref, keys)));
  }

  static Scope getBinder(InheritedBinderScope? inheritedScope) {
    if (inheritedScope == null) {
      throw StateError('No BinderScope found');
    }
    return inheritedScope.scope;
  }

  void write<X>(StateRef<X> ref, X state, [Object? action]) {
    assert(!debugDoingBuild, 'Cannot use write while building a widget.');
    readScope().write(ref, state, action);
  }
}
