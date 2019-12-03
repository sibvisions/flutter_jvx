
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// Model for the [SelectRecord] request.
class InsertRecord extends Request {
  String dataProvider;

  InsertRecord(this.dataProvider)  : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_INSERT);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
  };
}