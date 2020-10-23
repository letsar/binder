import 'dart:async';

import 'package:binder/binder.dart';

mixin Loadable on Logic {
  FutureOr<void> load();
}
