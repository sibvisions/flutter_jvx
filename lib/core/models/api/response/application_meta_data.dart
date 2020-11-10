import '../response_object.dart';

class ApplicationMetaData extends ResponseObject {
  String langCode;
  String languageResource;
  String clientId;
  String version;

  ApplicationMetaData(
      {this.langCode,
      this.languageResource,
      this.clientId,
      this.version});

  ApplicationMetaData.fromJson(Map<String, dynamic> json)
      : langCode = json['langCode'],
        languageResource = json['languageResource'],
        clientId = json['clientId'],
        version = json['version'],
        super.fromJson(json);
}
