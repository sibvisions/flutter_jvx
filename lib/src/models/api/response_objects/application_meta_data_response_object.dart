import 'package:flutterclient/src/models/api/response_object.dart';

class ApplicationMetaDataResponseObject extends ResponseObject {
  final String langCode;
  final String languageResource;
  final String clientId;
  final String version;
  final bool lostPasswordEnabled;

  ApplicationMetaDataResponseObject(
      {required String name,
      required this.langCode,
      required this.languageResource,
      required this.clientId,
      required this.version,
      required this.lostPasswordEnabled})
      : super(name: name);

  ApplicationMetaDataResponseObject.fromJson(
      {required Map<String, dynamic> map})
      : langCode = map['langCode'],
        languageResource = map['languageResource'],
        clientId = map['clientId'],
        version = map['version'],
        lostPasswordEnabled = map['lostPasswordEnabled'] ?? false,
        super.fromJson(map: map);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'langCode': langCode,
        'languageResource': languageResource,
        'clientId': clientId,
        'version': version,
        'lostPasswordEnabled': lostPasswordEnabled,
        ...super.toJson()
      };
}
