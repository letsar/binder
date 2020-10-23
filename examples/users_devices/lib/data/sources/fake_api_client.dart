import 'package:binder/binder.dart';
import 'package:users_devices/models/device.dart';
import 'package:users_devices/models/user.dart';

final apiClientRef = LogicRef((scope) => FakeApiClient());

const Duration _fakeDuration = Duration(milliseconds: 300);

const List<User> _initialUsers = <User>[
  User(id: 1, firstName: 'Alice', lastName: 'Alpha', deviceIds: <int>[2]),
  User(id: 2, firstName: 'Bob', lastName: 'Bravo', deviceIds: <int>[]),
  User(id: 3, firstName: 'Carole', lastName: 'Charlie', deviceIds: <int>[]),
  User(id: 4, firstName: 'Damien', lastName: 'Delta', deviceIds: <int>[3, 4]),
  User(id: 5, firstName: 'Estelle', lastName: 'Echo', deviceIds: <int>[]),
  User(id: 6, firstName: 'Franck', lastName: 'Ford', deviceIds: <int>[]),
];

const List<Device> _initialDevices = <Device>[
  Device(id: 1, name: 'Device 1'),
  Device(id: 2, name: 'Device 2', ownerId: 1),
  Device(id: 3, name: 'Device 3', ownerId: 4),
  Device(id: 4, name: 'Device 4', ownerId: 4),
  Device(id: 5, name: 'Device 5'),
  Device(id: 6, name: 'Device 6'),
  Device(id: 7, name: 'Device 7'),
  Device(id: 8, name: 'Device 8'),
  Device(id: 9, name: 'Device 9'),
];

class FakeApiClient {
  FakeApiClient()
      : _users = _initialUsers.toList(),
        _devices = _initialDevices.toList();

  final List<User> _users;
  final List<Device> _devices;

  Future<List<User>> getUsers() => _users.toList().withFakeDelay();

  Future<List<Device>> getDevices() => _devices.toList().withFakeDelay();
}

extension _Extensions<T> on T {
  Future<T> withFakeDelay() =>
      Future<T>.delayed(_fakeDuration).then((x) => this);
}
