import 'package:flutterclient/src/models/api/response_object.dart';

class UploadActionResponseObject extends ResponseObject {
  String fileId;

  UploadActionResponseObject.fromJson({required Map<String, dynamic> map})
      : fileId = map['fileId'],
        super.fromJson(map: map);
}
