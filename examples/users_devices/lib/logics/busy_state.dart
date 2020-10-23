import 'package:binder/binder.dart';

final busyRef = StateRef(BusyState.idle);

enum BusyState {
  idle,
  busy,
}

mixin BusyStateMixin on Logic {
  void idle() => write(busyRef, BusyState.idle);
  void busy() => write(busyRef, BusyState.busy);
}
