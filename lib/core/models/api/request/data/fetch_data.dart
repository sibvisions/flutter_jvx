import '../../request.dart';

class FetchData extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  int fromRow = -1;
  int rowCount = -1;
  bool includeMetaData = false;

  FetchData(this.dataProvider, String clientId,
      [this.columnNames, this.fromRow, this.rowCount, this.includeMetaData])
      : super(RequestType.DAL_FETCH, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'columnNames': columnNames,
        'fromRow': fromRow,
        'rowCount': rowCount,
        'includeMetaData': includeMetaData
      };
}
