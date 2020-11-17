import 'dart:io';

import '../request.dart';

class Upload extends Request {
  String fileId;
  File file;

  Upload({this.fileId, this.file, String clientId, RequestType requestType})
      : super(requestType, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fileId': fileId,
        'clientId': clientId,
        'name': 'upload'
      };
}
