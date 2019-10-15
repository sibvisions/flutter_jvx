import 'package:jvx_mobile_v3/model/api/response/response_object.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';

class ApplicationMetaData extends ResponseObject {
  String langCode;
  String languageResource;
  String clientId;
  String version;

  ApplicationMetaData(
      {this.langCode,
      this.languageResource,
      this.clientId,
      this.version}) {
    SharedPreferencesHelper().setAppVersion(this.version);
  }

  ApplicationMetaData.fromJson(Map<String, dynamic> json)
      : langCode = json['langCode'],
        languageResource = json['languageResource'],
        clientId = json['clientId'],
        version = json['version'],
        super.fromJson(json);
}
