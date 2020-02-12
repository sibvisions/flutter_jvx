
import '../../../../model/api/request/request.dart';
import '../../../../model/filter.dart';
import '../../../../utils/globals.dart' as globals;

/// Model for the [SelectRecord] request.
class FilterData extends Request {
  String dataProvider;
  String value;
  String editorComponentId;
  int fromRow = -1;
  int rowCount = -1;
  Filter filter = Filter();

  FilterData(this.dataProvider, this.value, this.editorComponentId, [this.filter, this.fromRow, this.rowCount])  : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_FILTER);

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