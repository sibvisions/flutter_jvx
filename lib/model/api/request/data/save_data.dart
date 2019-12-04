
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

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