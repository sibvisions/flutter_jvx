import '../../request.dart';
import '../../response/data/filter.dart';
import '../../response/data/filter_condition.dart';

class FilterData extends Request {
  String dataProvider;
  String value;
  String editorComponentId;
  int fromRow = -1;
  int rowCount = -1;
  Filter filter = Filter();
  FilterCondition condition;

  FilterData(
      this.dataProvider, this.value, this.editorComponentId, String clientId,
      [this.filter, this.fromRow, this.rowCount])
      : super(RequestType.DAL_FILTER, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'value': value,
        'editorComponentId': editorComponentId,
        'fromRow': fromRow,
        'rowCount': rowCount,
        'filter': filter?.toJson()
      };
}
