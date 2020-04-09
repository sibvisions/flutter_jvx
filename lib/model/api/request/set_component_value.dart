import '../../../model/api/request/request.dart';
import '../../../utils/globals.dart' as globals;

/// Model for [SetValues] request.
class SetComponentValue extends Request {
  String componentId;
  List<dynamic> values;

  SetComponentValue(this.componentId, this.values) : 
      super(clientId: globals.clientId, requestType: RequestType.SET_VALUE);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'componentId': componentId,
    'values': values,
  };
}