import 'package:flutterclient/src/models/api/request.dart';

class ApplicationStyleRequest extends Request {
  final String contentMode;

  @override
  String get debugInfo => 'clientId: $clientId, contentMode: $contentMode';

  ApplicationStyleRequest({
    required String clientId,
    this.contentMode = 'json',
  }) : super(
          clientId: clientId,
        );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': 'applicationStyle',
        'contentMode': contentMode,
        'libraryImages': false,
        'applicationImages': false,
        ...super.toJson()
      };
}
