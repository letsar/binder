import 'package:binder/binder.dart';

final busyRef = StateRef(false);

mixin BusyLogic on Logic {
  bool get busy => read(busyRef);
  set busy(bool value) => write(busyRef, value);
}
