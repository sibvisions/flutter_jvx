import '../../request.dart';
import '../../response/data/filter.dart';

class FetchData extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  int fromRow = -1;
  int rowCount = -1;
  bool includeMetaData = false;
  Filter filter;

  @override
  String get debugInfo {
    return dataProvider +
        ", From: $fromRow" +
        ", rowCount: $rowCount" +
        ", reload: $reload";
  }

  FetchData(this.dataProvider, String clientId,
      [this.columnNames,
      this.fromRow,
      this.rowCount,
      this.includeMetaData,
      this.filter])
      : super(RequestType.DAL_FETCH, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'columnNames': columnNames,
        'fromRow': fromRow,
        'rowCount': rowCount,
        "reload": reload,
        'includeMetaData': includeMetaData,
        'filter': filter?.toJson()
      };
}
