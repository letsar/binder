import 'dart:async';
import 'dart:math';

import 'package:binder/binder.dart';
import 'package:users_devices/models/device.dart';

import 'device_store.dart';
import 'loadable.dart';

final fakeConnectionRef =
    LogicRef((scope) => FakeConnectionStatusHandler(scope));

class FakeConnectionStatusHandler with Logic implements Loadable, Disposable {
  FakeConnectionStatusHandler(this.scope);

  @override
  final Scope scope;

  DeviceStore get _deviceStore => use(deviceStoreRef);
  Timer _timer;
  final Random _rnd = Random();

  @override
  void load() {
    _timer = Timer(const Duration(seconds: 2), _changeOneConnectionStatus);
  }

  void _changeOneConnectionStatus() {
    final Device randomDevice =
        _deviceStore.values.elementAt(_rnd.nextInt(_deviceStore.length));

    _deviceStore
        .overwrite(randomDevice.copyWith(connected: !randomDevice.connected));
    load();
  }

  @override
  void dispose() {
    _timer?.cancel();
  }
}
