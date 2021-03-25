import 'package:flutterclient/src/models/api/requests/data/data_request.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/data/filter.dart';

class SetValuesRequest extends DataRequest {
  List<dynamic> columnNames;
  List<dynamic> values;
  Filter? filter;
  int? offlineSelectedRow;

  SetValuesRequest(
      {required String clientId,
      required String dataProvider,
      String? debugInfo,
      bool reload = false,
      required this.values,
      required this.columnNames,
      this.filter,
      this.offlineSelectedRow})
      : super(
            clientId: clientId,
            dataProvider: dataProvider,
            debugInfo: debugInfo,
            reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'columnNames': columnNames,
        'values': values,
        'filter': filter != null ? filter!.toJson() : Filter().toJson(),
        ...super.toJson()
      };
}
