import 'package:flutter/foundation.dart';
import 'package:flutterclient/src/models/api/request.dart';

class DownloadImagesRequest extends Request {
  final String name;
  final bool libraryImages;
  final bool applicationImages;
  final String? contentMode;

  DownloadImagesRequest(
      {required String clientId,
      this.name = 'images',
      this.libraryImages = true,
      this.applicationImages = true})
      : this.contentMode = kIsWeb ? 'base64' : null,
        super(clientId: clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'libraryImages': libraryImages,
        'applicationImages': applicationImages,
        'clientId': clientId,
        'contentMode': contentMode
      };
}
