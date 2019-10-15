import 'package:jvx_mobile_v3/model/api/request/request.dart';

/// Model for the [Download] request.
class Download extends Request {
  String name;
  bool libraryImages;
  bool applicationImages;

  Download(
      {this.name,
      this.libraryImages,
      this.applicationImages,
      String clientId,
      RequestType requestType})
      : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => {
        'name': name,
        'libraryImages': libraryImages,
        'applicationImages': applicationImages,
        'clientId': clientId
      };
}
