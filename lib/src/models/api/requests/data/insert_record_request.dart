import 'data_request.dart';
import 'set_values_request.dart';

class InsertRecordRequest extends DataRequest {
  SetValuesRequest? setValues;

  @override
  String get debugInfo => 'clientId: $clientId, dataProvider: $dataProvider';

  InsertRecordRequest(
      {required String clientId,
      required String dataProvider,
      this.setValues,
      bool reload = false})
      : super(clientId: clientId, dataProvider: dataProvider, reload: reload);
}
