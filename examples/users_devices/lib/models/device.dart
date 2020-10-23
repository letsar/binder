import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:users_devices/models/identifiable.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
abstract class Device with _$Device implements Identifiable {
  const factory Device({
    @required int id,
    @required String name,
    int ownerId,
    @Default(false) bool connected,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
