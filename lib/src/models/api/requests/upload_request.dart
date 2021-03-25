import 'dart:io';

import 'package:flutterclient/src/models/api/request.dart';

class UploadRequest extends Request {
  String fileId;
  File file;

  UploadRequest(
      {required String clientId,
      String? debugInfo,
      bool reload = false,
      required this.fileId,
      required this.file})
      : super(clientId: clientId, debugInfo: debugInfo, reload: reload);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'fileId': fileId, 'name': 'upload', ...super.toJson()};
}
