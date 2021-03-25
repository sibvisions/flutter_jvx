import '../../response_objects/response_data/data/filter.dart';
import 'data_request.dart';

class FetchDataRequest extends DataRequest {
  List<dynamic> columnNames;
  int fromRow;
  int rowCount;
  bool includeMetaData;
  Filter? filter;

  FetchDataRequest(
      {required String dataProvider,
      required String clientId,
      String? debugInfo,
      bool reload = false,
      this.columnNames = const <dynamic>[],
      this.fromRow = -1,
      this.rowCount = -1,
      this.includeMetaData = false,
      this.filter})
      : super(
            clientId: clientId,
            debugInfo: debugInfo,
            dataProvider: dataProvider,
            reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'columnNames': columnNames,
        'fromRow': fromRow,
        'rowCount': rowCount,
        'reload': reload,
        'includeMetaData': includeMetaData,
        'filter': filter?.toJson(),
        ...super.toJson()
      };
}
