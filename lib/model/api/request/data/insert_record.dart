
import '../../../../model/api/request/request.dart';
import '../../../../utils/globals.dart' as globals;

/// Model for the [InsertRecord] request.
class InsertRecord extends Request {
  String dataProvider;

  InsertRecord(this.dataProvider)  : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_INSERT);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
  };
}