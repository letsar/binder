import 'package:binder/binder.dart';
import 'package:users_devices/data/sources/fake_api_client.dart';
import 'package:users_devices/logics/store.dart';
import 'package:users_devices/models/device.dart';

final deviceMapRef = StateRef(const <int, Device>{});
final deviceStoreRef = LogicRef((scope) => DeviceStore(scope));

class DeviceStore extends Store<Device> {
  DeviceStore(this.scope) : super(deviceMapRef);

  @override
  final Scope scope;

  FakeApiClient get _apiClient => use(apiClientRef);

  @override
  Future<Iterable<Device>> fetch() {
    return _apiClient.getDevices();
  }
}
