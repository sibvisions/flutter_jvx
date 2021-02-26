import '../../request.dart';
import '../../response/data/filter.dart';
import '../../response/data/filter_condition.dart';

class FetchData extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  int fromRow = -1;
  int rowCount = -1;
  bool includeMetaData = false;
  Filter filter;
  FilterCondition condition;

  @override
  String get debugInfo {
    return dataProvider +
        ", From: " +
        fromRow.toString() +
        ", rowCount: " +
        rowCount.toString();
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
        'includeMetaData': includeMetaData,
        'filter': filter?.toJson()
      };
}
