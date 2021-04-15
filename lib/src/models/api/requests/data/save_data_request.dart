import 'package:flutterclient/src/models/api/requests/data/data_request.dart';

class SaveDataRequest extends DataRequest {
  SaveDataRequest(
      {required String dataProvider,
      required String clientId,
      bool reload = false})
      : super(dataProvider: dataProvider, clientId: clientId, reload: reload);
}
