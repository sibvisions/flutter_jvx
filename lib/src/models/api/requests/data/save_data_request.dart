import 'package:flutterclient/src/models/api/requests/data/data_request.dart';

class SaveDataRequest extends DataRequest {
  SaveDataRequest(
      {required String dataProvider,
      required String clientId,
      String? debugInfo,
      bool reload = false})
      : super(
            dataProvider: dataProvider,
            clientId: clientId,
            debugInfo: debugInfo,
            reload: reload);
}
