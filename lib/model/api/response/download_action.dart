import '../../../model/api/response/response_object.dart';

class DownloadAction extends ResponseObject {
  String fileId;
  String fileName;

  DownloadAction({this.fileId});

  DownloadAction.fromJson(Map<String, dynamic> json)
    : fileId = json['fileId'],
      fileName = json['fileName'],
      super.fromJson(json);
}