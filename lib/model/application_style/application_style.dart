import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model Class for the [ApplicationStyle] request. 
class ApplicationStyle extends Request {
  String name = "applicationStyle";
  String contentMode = "json";
  bool libraryImages = false;
  bool applicationImages = false;

  ApplicationStyle({this.name, this.contentMode, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'name': name,
    'contentMode': contentMode,
    'libraryImages': libraryImages,
    'applicationImages': applicationImages
  };
}