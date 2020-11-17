import '../../request.dart';
import '../../response/data/filter.dart';

class SetValues extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  List<dynamic> values;
  Filter filter;

  SetValues(this.dataProvider, this.columnNames, this.values, String clientId,
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
