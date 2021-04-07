import 'package:flutterclient/src/models/api/requests/data/data_request.dart';

class MetaDataRequest extends DataRequest {
  List<dynamic>? columnNames;

  MetaDataRequest(
      {required String dataProvider,
      required String clientId,
      this.columnNames,
      String? debugInfo,
      bool reload = false})
      : super(
            dataProvider: dataProvider,
            clientId: clientId,
            debugInfo: debugInfo,
            reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'columnNames': columnNames, ...super.toJson()};
}
