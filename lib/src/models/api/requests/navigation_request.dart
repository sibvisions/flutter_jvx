import 'package:flutterclient/src/models/api/request.dart';

class NavigationRequest extends Request {
  String componentId;

  @override
  String get debugInfo => 'clientId: $clientId, componentId: $componentId';

  NavigationRequest(
      {required this.componentId,
      required String clientId,
      bool reload = false})
      : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, ...super.toJson()};
}
