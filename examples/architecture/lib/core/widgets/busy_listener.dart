import 'dart:ui';

import 'package:architecture/core/logics/busy.dart';
import 'package:binder/binder.dart';
import 'package:flutter/material.dart';

class BusyListener extends StatelessWidget {
  const BusyListener({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final busy = context.watch(busyRef);
    return AbsorbPointer(
      absorbing: busy,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          child,
          if (busy) ...[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
