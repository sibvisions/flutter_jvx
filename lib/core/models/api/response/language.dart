import '../response_object.dart';

class Language extends ResponseObject {
  String langCode;
  String languageResource;

  Language({this.langCode, this.languageResource});

  Language.fromJson(Map<String, dynamic> json)
    : langCode = json['langCode'],
      languageResource = json['languageResource'],
      super.fromJson(json);
}