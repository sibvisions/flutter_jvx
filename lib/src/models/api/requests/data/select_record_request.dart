import 'package:flutterclient/src/models/api/requests/data/data_request.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/data/filter.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';

import '../../../../ui/screen/core/so_component_data.dart';

class SelectRecordRequest extends DataRequest {
  bool fetch;
  Filter? filter = Filter();
  int selectedRow;
  SoComponentData? soComponentData;

  SelectRecordRequest(
      {required String clientId,
      required String dataProvider,
      String? debugInfo,
      bool reload = false,
      required this.filter,
      required this.selectedRow,
      this.fetch = false})
      : super(
            clientId: clientId,
            dataProvider: dataProvider,
            debugInfo: debugInfo,
            reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fetch': fetch,
        'filter': filter?.toJson(),
        'selectedRow': selectedRow,
        ...super.toJson()
      };
}
