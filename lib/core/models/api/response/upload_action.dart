import '../response_object.dart';

class UploadAction extends ResponseObject {
  String fileId;

  UploadAction({this.fileId});

  UploadAction.fromJson(Map<String, dynamic> json)
      : fileId = json['fileId'],
        super.fromJson(json);
}
