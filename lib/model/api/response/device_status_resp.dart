import 'response_object.dart';

class DeviceStatusResponse extends ResponseObject {
  String layoutMode;

  DeviceStatusResponse({this.layoutMode});

  DeviceStatusResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    layoutMode = json['layoutMode'];
  }
}
