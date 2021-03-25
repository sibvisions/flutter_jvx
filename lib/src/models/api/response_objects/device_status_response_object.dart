import 'package:flutterclient/src/models/api/response_object.dart';

class DeviceStatusResponseObject extends ResponseObject {
  final String layoutMode;

  DeviceStatusResponseObject({required String name, required this.layoutMode})
      : super(name: name);

  DeviceStatusResponseObject.fromJson({required Map<String, dynamic> map})
      : layoutMode = map['layoutMode'],
        super.fromJson(map: map);
}
