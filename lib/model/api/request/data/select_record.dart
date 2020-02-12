
import '../../../../model/api/request/request.dart';
import '../../../../model/filter.dart';
import '../../../../utils/globals.dart' as globals;

/// Model for the [SelectRecord] request.
class SelectRecord extends Request {
  String dataProvider;
  bool fetch;
  Filter filter = Filter();
  int selectedRow;

  SelectRecord(this.dataProvider, this.filter, this.selectedRow, RequestType requestType, [this.fetch])  : 
      super(clientId: globals.clientId, requestType: requestType);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'fetch': fetch,
    'filter': filter?.toJson()
  };
}