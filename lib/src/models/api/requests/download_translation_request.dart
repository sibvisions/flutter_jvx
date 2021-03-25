import 'package:flutterclient/src/models/api/request.dart';

class DownloadTranslationRequest extends Request {
  final String name;
  final bool libraryImages;
  final bool applicationImages;
  final String contentMode;

  DownloadTranslationRequest(
      {required String clientId,
      this.name = 'translation',
      this.libraryImages = false,
      this.applicationImages = false,
      this.contentMode = 'json'})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'libraryImages': libraryImages,
        'applicationImages': applicationImages,
        'clientId': clientId,
        'contentMode': contentMode
      };
}
