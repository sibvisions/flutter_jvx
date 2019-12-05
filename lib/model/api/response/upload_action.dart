import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

class UploadAction extends ResponseObject {
  String fileId;

  UploadAction({this.fileId});

  UploadAction.fromJson(Map<String, dynamic> json)
    : fileId = json['fileId'],
      super.fromJson(json);
}