import '../../response_objects/response_data/data/filter.dart';
import 'data_request.dart';

class FetchDataRequest extends DataRequest {
  List<dynamic> columnNames;
  int? fromRow;
  int? rowCount;
  bool? includeMetaData;
  Filter? filter;

  @override
  String get debugInfo =>
      'clientId: $clientId, dataProvider: $dataProvider, columnNames: $columnNames, fromRow: $fromRow, rowCount: $rowCount, includeMetaData: $includeMetaData,';

  FetchDataRequest(
      {required String dataProvider,
      required String clientId,
      bool reload = false,
      this.columnNames = const <dynamic>[],
      this.fromRow,
      this.rowCount,
      this.includeMetaData,
      this.filter})
      : super(clientId: clientId, dataProvider: dataProvider, reload: reload);

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
