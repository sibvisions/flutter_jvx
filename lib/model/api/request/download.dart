import '../../../model/api/request/request.dart';

/// Model for the [Download] request.
class Download extends Request {
  String name;
  bool libraryImages;
  bool applicationImages;
  String fileId;
  String contentMode = "json";

  Download(
      {this.name,
      this.libraryImages,
      this.applicationImages,
      this.fileId,
      this.contentMode,
      String clientId,
      RequestType requestType})
      : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
        'name': name,
        'libraryImages': libraryImages,
        'applicationImages': applicationImages,
        'clientId': clientId,
        'fileId': fileId,
        'contentMode': contentMode
      };
}
