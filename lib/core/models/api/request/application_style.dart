import '../request.dart';

class ApplicationStyle extends Request {
  String name = "applicationStyle";
  String contentMode = "json";
  bool libraryImages = false;
  bool applicationImages = false;

  @override
  String get debugInfo {
    return contentMode;
  }

  ApplicationStyle(
      {this.name, this.contentMode, String clientId, RequestType requestType})
      : super(requestType, clientId);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
        'name': name,
        'contentMode': contentMode,
        'libraryImages': libraryImages,
        'applicationImages': applicationImages
      };
}
