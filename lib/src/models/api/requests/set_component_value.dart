import 'package:flutterclient/src/models/api/request.dart';

class SetComponentValueRequest extends Request {
  String componentId;
  dynamic value;

  SetComponentValueRequest(
      {required String clientId,
      String? debugInfo,
      bool reload = false,
      required this.componentId,
      required this.value})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'componentId': componentId,
        'value': value,
        ...super.toJson()
      };
}
