import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// Model for [FetchData] request.
class FetchData extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  int fromRow = -1;
  int rowCount = -1;

  FetchData(this.dataProvider, [this.columnNames, this.fromRow, this.rowCount]) : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_FETCH);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'columnNames': columnNames,
    'fromRow': fromRow,
    'rowCount': rowCount,
  };
}