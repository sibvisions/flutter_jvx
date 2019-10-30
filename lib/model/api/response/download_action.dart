import 'package:jvx_mobile_v3/model/api/response/response_object.dart';

class DownloadAction extends ResponseObject {
  String fileId;

  DownloadAction({this.fileId});

  DownloadAction.fromJson(Map<String, dynamic> json)
    : fileId = json['fileId'],
      super.fromJson(json);
}