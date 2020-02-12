
import '../../../../model/api/request/request.dart';
import '../../../../utils/globals.dart' as globals;

/// Model for the [SaveData] request.
class SaveData extends Request {
  String dataProvider;

  SaveData(this.dataProvider)  : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_SAVE);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
  };
}