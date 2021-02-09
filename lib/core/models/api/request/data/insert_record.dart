import 'package:jvx_flutterclient/core/models/api/request/data/set_values.dart';

import '../../request.dart';

class InsertRecord extends Request {
  String dataProvider;
  SetValues setValues;

  @override
  String get debugInfo {
    return dataProvider;
  }

  InsertRecord(this.dataProvider, String clientId)
      : super(RequestType.DAL_INSERT, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
      };
}
