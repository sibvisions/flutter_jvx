import 'device_info_stub.dart'
    if (dart.library.io) 'device_info_mobile.dart'
    if (dart.library.html) 'device_info_web.dart';

abstract class DeviceInfo {
  String osName;
  String osVersion;
  String appVersion;
  String deviceType;
  String deviceTypeModel;
  String technology;

  factory DeviceInfo() => getDeviceInfo();
}
