import '../../../../model/api/request/request.dart';
import '../../../../utils/globals.dart' as globals;

/// Model for [MetaData] request.
class MetaData extends Request {
  String dataProvider;
  List<dynamic> columnNames;

  MetaData(this.dataProvider, [this.columnNames]) : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_METADATA);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'columnNames': columnNames,
  };
}