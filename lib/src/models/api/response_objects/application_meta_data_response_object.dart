import 'package:flutterclient/src/models/api/response_object.dart';

class ApplicationMetaDataResponseObject extends ResponseObject {
  final String langCode;
  final String languageResource;
  final String clientId;
  final String version;

  ApplicationMetaDataResponseObject(
      {required String name,
      required this.langCode,
      required this.languageResource,
      required this.clientId,
      required this.version})
      : super(name: name);

  ApplicationMetaDataResponseObject.fromJson(
      {required Map<String, dynamic> map})
      : langCode = map['langCode'],
        languageResource = map['languageResource'],
        clientId = map['clientId'],
        version = map['version'],
        super.fromJson(map: map);
}
