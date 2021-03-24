import 'dart:ui';

import 'package:flutter/foundation.dart';

class BinderKey {
  const BinderKey(this.name);
  final String name;
}

mixin BinderContainerMixin {
  Map<BinderKey, Object?> get states;
  BinderContainerMixin? get parent;

  bool isOwner(BinderKey key) {
    // We only write in this container if:
    // - It's the first container.
    // - The ref has already a state in the container (overriden in this scope).
    return parent == null || states.containsKey(key);
  }

  T fetch<T>(BinderKey key, T defaultState) {
    if (isOwner(key)) {
      if (states.containsKey(key)) {
        return states[key] as T;
      } else {
        return defaultState;
      }
    } else {
      return parent!.fetch(key, defaultState);
    }
  }
}

@immutable
class BinderContainer with BinderContainerMixin {
  const BinderContainer(this.states, this.parent);

  @override
  final Map<BinderKey, Object?> states;

  @override
  final BinderContainer? parent;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is BinderContainer &&
        other.states == states &&
        other.parent == parent;
  }

  @override
  int get hashCode {
    return hashValues(states, parent);
  }
}
