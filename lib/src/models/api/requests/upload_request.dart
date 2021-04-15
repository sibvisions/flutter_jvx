import 'dart:io';

import 'package:flutterclient/src/models/api/request.dart';

class UploadRequest extends Request {
  String fileId;
  File file;

  @override
  String get debugInfo => 'clientId: $clientId, fileId: $fileId';

  UploadRequest(
      {required String clientId,
      bool reload = false,
      required this.fileId,
      required this.file})
      : super(clientId: clientId, reload: reload);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fileId': fileId,
        'name': 'upload',
        'file': file,
        ...super.toJson()
      };
}
