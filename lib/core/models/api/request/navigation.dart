import '../request.dart';

class Navigation extends Request {
  String componentId;

  @override
  String get debugInfo {
    return componentId;
  }

  Navigation({this.componentId, String clientId})
      : super(RequestType.NAVIGATION, clientId);

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, 'clientId': clientId};
}
