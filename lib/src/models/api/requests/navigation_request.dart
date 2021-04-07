import 'package:flutterclient/src/models/api/request.dart';

class NavigationRequest extends Request {
  String componentId;

  NavigationRequest(
      {required this.componentId,
      required String clientId,
      String? debugInfo,
      bool reload = false})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, ...super.toJson()};
}
