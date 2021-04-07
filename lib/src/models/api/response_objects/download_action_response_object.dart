import 'package:flutterclient/src/models/api/response_object.dart';

class DownloadActionResponseObject extends ResponseObject {
  String fileId;
  String fileName;

  DownloadActionResponseObject.fromJson({required Map<String, dynamic> map})
      : fileId = map['fileId'],
        fileName = map['fileName'],
        super.fromJson(map: map);
}
