import 'data_request.dart';
import 'set_values_request.dart';

class InsertRecordRequest extends DataRequest {
  SetValuesRequest? setValues;

  InsertRecordRequest(
      {required String clientId,
      required String dataProvider,
      this.setValues,
      String? debugInfo,
      bool reload = false})
      : super(
            clientId: clientId,
            dataProvider: dataProvider,
            debugInfo: debugInfo,
            reload: reload);
}
