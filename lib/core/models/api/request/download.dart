import '../request.dart';

class Download extends Request {
  final String name;
  final bool libraryImages;
  final bool applicationImages;
  final String fileId;
  final String contentMode;

  Download(
      {this.name,
      this.libraryImages,
      this.applicationImages,
      this.fileId,
      this.contentMode = "json",
      String clientId,
      RequestType requestType})
      : super(requestType, clientId);

  Map<String, dynamic> toJson() => {
        'name': name,
        'libraryImages': libraryImages,
        'applicationImages': applicationImages,
        'clientId': clientId,
        'fileId': fileId,
        'contentMode': contentMode
      };
}
