import 'package:flutterclient/src/models/api/request.dart';

class CloseScreenRequest extends Request {
  String componentId;

  @override
  String get debugInfo => 'clientId: $clientId, componentId: $componentId';

  CloseScreenRequest(
      {required String clientId,
      required this.componentId,
      bool reload = false})
      : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, ...super.toJson()};
}
