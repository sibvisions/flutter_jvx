import 'package:flutterclient/src/models/api/request.dart';

class ApplicationStyleRequest extends Request {
  final String contentMode;

  ApplicationStyleRequest({
    required String clientId,
    String? debugInfo,
    this.contentMode = 'json',
  }) : super(clientId: clientId, debugInfo: debugInfo);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': 'applicationStyle',
        'contentMode': contentMode,
        'libraryImages': false,
        'applicationImages': false,
        ...super.toJson()
      };
}
