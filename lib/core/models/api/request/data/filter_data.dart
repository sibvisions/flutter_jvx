import '../../request.dart';
import '../../response/data/filter.dart';
import '../../response/data/filter_condition.dart';

class FilterData extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  String value;
  String editorComponentId;
  int fromRow = -1;
  int rowCount = -1;
  bool includeMetaData = false;
  Filter filter = Filter();
  FilterCondition condition;

  FilterData(
      this.dataProvider, this.value, this.editorComponentId, String clientId,
      [this.filter, this.fromRow, this.rowCount])
      : super(RequestType.DAL_FILTER, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'columnNames': columnNames,
        'value': value,
        'editorComponentId': editorComponentId,
        'fromRow': fromRow,
        'rowCount': rowCount,
        'includeMetaData': includeMetaData,
        'filter': filter?.toJson()
      };
}
