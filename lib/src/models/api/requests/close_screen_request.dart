import 'package:flutterclient/src/models/api/request.dart';

class CloseScreenRequest extends Request {
  String componentId;

  CloseScreenRequest(
      {required String clientId,
      required this.componentId,
      String? debugInfo,
      bool reload = false})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, ...super.toJson()};
}
