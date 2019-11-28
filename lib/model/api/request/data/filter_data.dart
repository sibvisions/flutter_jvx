
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// Model for the [SelectRecord] request.
class FilterData extends Request {
  String dataProvider;
  dynamic value;
  String editorComponentId;

  FilterData(this.dataProvider, this.value, this.editorComponentId)  : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_FILTER);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'value': value,
    'editorComponentId': editorComponentId
  };
}