import 'package:flutterclient/src/models/api/response_object.dart';

class AuthenticationDataResponseObject extends ResponseObject {
  final String authKey;

  AuthenticationDataResponseObject(
      {required String name, String? componentId, required this.authKey})
      : super(name: name, componentId: componentId);

  AuthenticationDataResponseObject.fromJson({required Map<String, dynamic> map})
      : authKey = map['authKey'],
        super.fromJson(map: map);
}
