import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

class ApplicationMetaData {
  String langCode;
  String name;
  String languageResource;
  String clientId;
  String version;

  ApplicationMetaData({this.langCode, this.name, this.languageResource, this.clientId, this.version}) {
    SharedPreferencesHelper().setAppVersion(this.version);
  }

  ApplicationMetaData.fromJson(Map<String, dynamic> json)
    : langCode = json['langCode'],
      name = json['name'],
      languageResource = json['languageResource'],
      clientId = json['clientId'],
      version = json['version'];
}