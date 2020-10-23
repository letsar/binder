import 'package:binder/binder.dart';
import 'package:users_devices/logics/device_store.dart';
import 'package:users_devices/logics/user_store.dart';
import 'package:users_devices/models/device.dart';
import 'package:users_devices/models/user.dart';

final deviceAssigmentRef = LogicRef((scope) => DeviceAssigmentLogic(scope));

class DeviceAssigmentLogic with Logic {
  const DeviceAssigmentLogic(this.scope);

  @override
  final Scope scope;

  UserStore get _userStore => use(userStoreRef);
  DeviceStore get _deviceStore => use(deviceStoreRef);

  /// Assign the device with this [deviceId] to the user with this [userId].
  void assign(int deviceId, int userId) {
    final User user = _userStore.get(userId);
    final Device device = _deviceStore.get(deviceId);

    if (user != null && device != null) {
      if (device.ownerId != null) {
        // The device was assigned to another user before.
        // After the assignment, it should only by assigned to one person only.
        final User owner = _userStore.get(device.ownerId);
        final User newOwner = owner.newDeviceIds((l) => l..remove(deviceId));
        _userStore.overwrite(newOwner);
      }

      // We change the owner of the device.
      final Device newDevice = device.copyWith(ownerId: userId);

      // We assign the device to the user.
      final User newUser = user.newDeviceIds((l) => l..add(deviceId));

      // We persist the data.
      _userStore.overwrite(newUser);
      _deviceStore.overwrite(newDevice);
    }
  }
}
