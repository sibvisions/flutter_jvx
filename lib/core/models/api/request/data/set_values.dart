import '../../request.dart';
import '../../response/data/filter.dart';
import '../../response/data/filter_condition.dart';

class SetValues extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  List<dynamic> values;
  Filter filter;
  int offlineSelectedRow;
  FilterCondition condition;

  @override
  String get debugInfo {
    return dataProvider +
        ", ColumnNames: " +
        columnNames.toString() +
        ", Values: " +
        values.toString();
  }

  SetValues(this.dataProvider, this.columnNames, this.values, String clientId,
      this.offlineSelectedRow,
      [this.filter])
      : super(RequestType.DAL_SET_VALUE, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'dataProvider': dataProvider,
        'columnNames': columnNames,
        'values': values,
        'filter': filter != null ? filter.toJson() : Filter().toJson()
      };
}
