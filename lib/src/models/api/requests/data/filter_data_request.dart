import '../../response_objects/response_data/data/filter.dart';
import '../../response_objects/response_data/data/filter_condition.dart';
import 'data_request.dart';

class FilterDataRequest extends DataRequest {
  List<dynamic>? columnNames;
  String? value;
  String? editorComponentId;
  int fromRow;
  int rowCount;
  bool includeMetaData = false;
  Filter? filter = Filter();
  FilterCondition? condition;

  @override
  String get debugInfo =>
      'clientId: $clientId, dataProvider: $dataProvider, columnNames: $columnNames, value: $value, fromRow: $fromRow, rowCount: $rowCount, includeMetaData: $includeMetaData,';

  FilterDataRequest({
    required String dataProvider,
    required String clientId,
    bool reload = false,
    this.columnNames,
    this.value,
    this.editorComponentId,
    this.condition,
    this.fromRow = -1,
    this.rowCount = -1,
    this.includeMetaData = false,
    bool showLoading = true,
  }) : super(
            dataProvider: dataProvider,
            clientId: clientId,
            reload: reload,
            showLoading: showLoading);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'columnNames': columnNames,
        'value': value,
        'editorComponentId': editorComponentId,
        'fromRow': fromRow,
        'rowCount': rowCount,
        'includeMetaData': includeMetaData,
        'filter': filter?.toJson(),
        ...super.toJson()
      };
}
