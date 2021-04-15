import 'package:flutterclient/src/models/api/requests/data/data_request.dart';

class MetaDataRequest extends DataRequest {
  List<dynamic>? columnNames;

  @override
  String get debugInfo =>
      'clientId: $clientId, dataProvider: $dataProvider, columnNames: $columnNames';

  MetaDataRequest(
      {required String dataProvider,
      required String clientId,
      this.columnNames,
      bool reload = false})
      : super(dataProvider: dataProvider, clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'columnNames': columnNames, ...super.toJson()};
}
