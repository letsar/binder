import 'package:flutter/material.dart';

abstract class GenericPopupMenuEntry<T> extends PopupMenuEntry<T> {
  const GenericPopupMenuEntry({
    Key key,
  }) : super(key: key);

  T get value;

  @override
  double get height => kMinInteractiveDimension;

  @override
  bool represents(T value) => value == this.value;

  @override
  _GenericPopupMenuEntryState createState() => _GenericPopupMenuEntryState();

  @protected
  Widget build(BuildContext context);
}

class _GenericPopupMenuEntryState extends State<GenericPopupMenuEntry> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }
}
