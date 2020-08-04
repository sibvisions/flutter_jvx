import 'package:jvx_flutterclient/model/api/response/response_object.dart';

class DeviceStatus extends ResponseObject {
  String layoutMode;

  DeviceStatus({this.layoutMode});

  DeviceStatus.fromJson(Map<String, dynamic> json)
      : layoutMode = json['layoutMode'];
}
