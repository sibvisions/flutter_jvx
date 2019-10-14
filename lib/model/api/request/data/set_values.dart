import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// Model for [SetValues] request.
class SetValues extends Request {
  String dataProvider;
  List<dynamic> columnNames;
  List<dynamic> values;
  Filter filter = Filter();

  SetValues(this.dataProvider, this.columnNames, this.values, [this.filter]) : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_SET_VALUE);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'columnNames': columnNames,
    'values': values,
    'filter': filter?.toJson()
  };
}