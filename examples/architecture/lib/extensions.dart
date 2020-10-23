import 'package:flutter/material.dart';

const _defaultDelay = Duration(milliseconds: 500);

extension FutureX<T> on Future<T> {
  Future<T> fakeDelay() {
    return Future<void>.delayed(_defaultDelay).then((_) => this);
  }
}
