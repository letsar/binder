import 'package:binder/binder.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:users_devices/logics/loadable.dart';

import '../models/identifiable.dart';

abstract class Store<T extends Identifiable> with Logic implements Loadable {
  Store(this.ref);
  final StateRef<Map<int, T>> ref;

  Map<int, T> get state => read(ref);
  set state(Map<int, T> value) => write(ref, value);

  T operator [](int id) => read(ref)[id];
  void operator []=(int id, T value) {
    final newState = state.clone();
    newState[id] = value;
    state = newState;
  }

  int get length => state.length;

  List<T> get values => state.values.toList();

  T get(int id) => state[id];

  void overwrite(T newValue) {
    this[newValue.id] = newValue;
  }

  @override
  Future<void> load() async {
    // busy();
    final Iterable<T> all = await fetch();
    state = Map<int, T>.fromEntries(all.map((e) => MapEntry<int, T>(e.id, e)));
    // idle();
  }

  @protected
  Future<Iterable<T>> fetch();
}

extension _MapExtensions<T extends Identifiable> on Map<int, T> {
  Map<int, T> clone() => Map<int, T>.from(this);
}
