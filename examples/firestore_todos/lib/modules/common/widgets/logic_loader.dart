import 'dart:async';

import 'package:flutter/material.dart';

class LogicLoader extends StatefulWidget {
  const LogicLoader({
    Key key,
    @required this.child,
    @required this.loader,
  })  : assert(child != null),
        assert(loader != null),
        super(key: key);

  final void Function(BuildContext context) loader;
  final Widget child;

  @override
  _LogicLoaderState createState() => _LogicLoaderState();
}

class _LogicLoaderState extends State<LogicLoader> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => widget.loader(context));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
