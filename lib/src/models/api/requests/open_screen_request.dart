import 'package:flutterclient/src/models/api/request.dart';

class OpenScreenRequest extends Request {
  bool manualClose;
  String componentId;
  Map<String, dynamic> parameter;

  @override
  String get debugInfo =>
      'clientId: $clientId, componentId: $componentId, manualClose: $manualClose';

  OpenScreenRequest({
    required String clientId,
    bool reload = false,
    required this.componentId,
    this.parameter = const <String, dynamic>{},
    this.manualClose = false,
  }) : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'manualClose': manualClose,
        'componentId': componentId,
        'parameter': parameter,
        ...super.toJson()
      };
}
