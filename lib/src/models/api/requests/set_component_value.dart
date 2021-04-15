import 'package:flutterclient/src/models/api/request.dart';

class SetComponentValueRequest extends Request {
  String componentId;
  dynamic value;

  @override
  String get debugInfo =>
      'clientId: $clientId, componentId: $componentId, value: $value';

  SetComponentValueRequest(
      {required String clientId,
      bool reload = false,
      required this.componentId,
      required this.value})
      : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'componentId': componentId,
        'value': value,
        ...super.toJson()
      };
}
