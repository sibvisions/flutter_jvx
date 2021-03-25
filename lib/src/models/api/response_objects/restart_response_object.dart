import 'package:flutterclient/src/models/api/response_object.dart';

class RestartResponseObject extends ResponseObject {
  String info;

  RestartResponseObject(
      {required String name, String? componentId, required this.info})
      : super(name: name, componentId: componentId);

  RestartResponseObject.fromJson({required Map<String, dynamic> map})
      : info = map['info'],
        super.fromJson(map: map);
}
