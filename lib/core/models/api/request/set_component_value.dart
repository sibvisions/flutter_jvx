import '../request.dart';

class SetComponentValue extends Request {
  String componentId;
  dynamic value;

  SetComponentValue(this.componentId, this.value, String clientId)
      : super(RequestType.SET_VALUE, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'componentId': componentId,
        'value': value,
      };
}
