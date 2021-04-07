import 'package:flutterclient/src/models/api/request.dart';

class PressButtonRequest extends Request {
  String componentId;
  String? classNameEventSourceRef;

  PressButtonRequest(
      {required String clientId,
      String? debugInfo,
      bool reload = false,
      required this.componentId,
      this.classNameEventSourceRef})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, ...super.toJson()};
}
