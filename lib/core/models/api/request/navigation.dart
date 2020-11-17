import '../request.dart';

class Navigation extends Request {
  String componentId;

  Navigation({this.componentId, String clientId})
      : super(RequestType.NAVIGATION, clientId);

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, 'clientId': clientId};
}
