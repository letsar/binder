import 'package:binder/binder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:users_devices/core/widgets/sliver_pinned_header.dart';
import 'package:users_devices/logics/loadable.dart';
import 'package:users_devices/logics/user_store.dart';
import 'package:users_devices/logics/device_store.dart';
import 'package:users_devices/logics/fake_connection_status_handler.dart';
import 'package:users_devices/logics/device_assignment.dart';
import 'package:users_devices/models/device.dart';
import 'package:users_devices/models/user.dart';

final unassignedDevicesRef = Computed(
  (watch) => watch(
    deviceMapRef.select(
      (devices) =>
          devices.values.where((device) => device.ownerId == null).toList(),
    ),
  ),
);

final assignedDevicesRef = Computed(
  (watch) => watch(
    deviceMapRef.select(
      (map) => watch(
        userRef.select(
          (user) => user.deviceIds.map((id) => map[id]).toList(),
        ),
      ),
    ),
  ),
);

final deviceListRef = StateRef(const <Device>[]);
final deviceRef = StateRef<Device>(null);
final userRef = StateRef<User>(null);

class Load extends StatefulWidget {
  const Load({
    Key key,
    this.refs,
    this.child,
  }) : super(key: key);

  final List<LogicRef<Loadable>> refs;
  final Widget child;

  @override
  _LoadState createState() => _LoadState();
}

class _LoadState extends State<Load> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.refs.forEach((ref) => context.use(ref).load());
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A widget.
class AssignmentPage extends StatelessWidget {
  /// Creates a [AssignmentPage].
  const AssignmentPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Load(
      refs: [
        userStoreRef,
        deviceStoreRef,
        fakeConnectionRef,
      ],
      child: const Scaffold(
        body: SafeArea(
          child: _Page(),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: <Widget>[
        SliverPinnedHeader(
          height: 120,
          child: _UnassignedDevices(),
        ),
        _Users(),
      ],
    );
  }
}

class _Users extends StatelessWidget {
  const _Users({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<User> users =
        context.watch(userMapRef.select((userMap) => userMap.values.toList()));

    return SliverFixedExtentList(
      itemExtent: 120,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return BinderScope(
            overrides: [userRef.overrideWith(users[index])],
            child: const _Assignments(),
          );
        },
        childCount: users.length,
      ),
    );
  }
}

class _UnassignedDevices extends StatelessWidget {
  const _UnassignedDevices({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Device> devices = context.watch(unassignedDevicesRef);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white),
      child: BinderScope(
        overrides: [deviceListRef.overrideWith(devices)],
        child: const _DeviceList(),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Device> devices = context.watch(deviceListRef);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return BinderScope(
          overrides: [deviceRef.overrideWith(devices[index])],
          child: const _Device(),
        );
      },
    );
  }
}

class _Device extends StatelessWidget {
  const _Device({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int deviceId =
        context.watch(deviceRef.select((Device device) => device.id));
    final bool connected =
        context.watch(deviceRef.select((Device device) => device.connected));

    final Widget item = _Item(
      backgroundColor: connected ? Colors.green : Colors.grey,
      text: deviceId.toString(),
    );

    return Draggable<int>(
      data: deviceId,
      feedback: item,
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: item,
      ),
      child: item,
    );
  }
}

class _Assignments extends StatelessWidget {
  const _Assignments({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Device> assignedDevices = context.watch(assignedDevicesRef);

    return BinderScope(
      overrides: [deviceListRef.overrideWith(assignedDevices)],
      child: Row(
        children: const <Widget>[
          _UserAvatar(),
          Expanded(
            child: _AssignedDevices(),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool connected = context.watch(deviceListRef.select(
        (assignedDevices) =>
            assignedDevices.any((device) => device.connected)));
    final String initials =
        context.watch(userRef.select((user) => user.initials));

    final Widget child = _Item(
      text: initials,
      backgroundColor: connected ? Colors.green.shade900 : Colors.blue.shade900,
    );

    return DragTarget<int>(
      onWillAccept: (deviceId) =>
          !context.read(userRef).deviceIds.contains(deviceId),
      onAccept: (deviceId) {
        context
            .use(deviceAssigmentRef)
            .assign(deviceId, context.read(userRef).id);
      },
      builder: (context, candidateData, rejectedData) {
        return child;
      },
    );
  }
}

class _AssignedDevices extends StatelessWidget {
  const _AssignedDevices({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
      child: _DeviceList(),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key key,
    @required this.text,
    this.backgroundColor,
    this.foregroundColor,
  })  : assert(text != null),
        super(key: key);

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? Colors.white,
        minRadius: 40,
        child: Text(text),
      ),
    );
  }
}
