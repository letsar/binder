import 'package:binder/binder.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class LogicLoader extends StatefulWidget {
  const LogicLoader({
    Key key,
    @required this.loader,
    @required this.child,
  })  : assert(loader != null),
        assert(child != null),
        super(key: key);

  final Widget child;
  final void Function(BuildContext context) loader;

  @override
  _LogicLoaderState createState() => _LogicLoaderState();
}

class _LogicLoaderState extends State<LogicLoader> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.loader(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
