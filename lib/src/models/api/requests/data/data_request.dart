import 'package:flutterclient/src/models/api/request.dart';

class DataRequest extends Request {
  final String dataProvider;

  DataRequest(
      {required String clientId,
      String? debugInfo,
      bool reload = false,
      required this.dataProvider})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'dataProvider': dataProvider, ...super.toJson()};
}
