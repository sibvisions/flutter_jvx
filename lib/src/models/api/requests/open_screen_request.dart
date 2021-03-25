import 'package:flutterclient/src/models/api/request.dart';

class OpenScreenRequest extends Request {
  bool manualClose;
  String componentId;

  OpenScreenRequest({
    required String clientId,
    String? debugInfo,
    bool reload = false,
    required this.componentId,
    this.manualClose = false,
  }) : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'manualClose': manualClose,
        'componentId': componentId,
        ...super.toJson()
      };
}
