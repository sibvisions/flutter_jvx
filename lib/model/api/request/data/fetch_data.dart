import '../../../../model/api/request/request.dart';
import '../../../../utils/globals.dart' as globals;

/// Model for [FetchData] request.
class FetchData extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  int fromRow = -1;
  int rowCount = -1;
  bool includeMetaData = false;

  FetchData(this.dataProvider, [this.columnNames, this.fromRow, this.rowCount, this.includeMetaData]) : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_FETCH);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'columnNames': columnNames,
    'fromRow': fromRow,
    'rowCount': rowCount,
    'includeMetaData': includeMetaData
  };
}