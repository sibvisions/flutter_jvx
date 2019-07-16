class ApplicationMetaData {
  String langCode;
  String name;
  String languageResource;
  String clientId;
  String version;

  ApplicationMetaData({this.langCode, this.name, this.languageResource, this.clientId, this.version});

  ApplicationMetaData.fromJson(Map<String, dynamic> json)
    : langCode = json['langCode'],
      name = json['name'],
      languageResource = json['languageResource'],
      clientId = json['clientId'],
      version = json['version'];
}