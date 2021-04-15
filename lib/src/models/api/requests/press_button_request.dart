import 'package:flutterclient/src/models/api/request.dart';

class PressButtonRequest extends Request {
  String componentId;
  String? classNameEventSourceRef;

  @override
  String get debugInfo =>
      'clientId: $clientId, componentId: $componentId, classNameEventSourceRef: $classNameEventSourceRef';

  PressButtonRequest(
      {required String clientId,
      bool reload = false,
      required this.componentId,
      this.classNameEventSourceRef})
      : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'componentId': componentId, ...super.toJson()};
}
