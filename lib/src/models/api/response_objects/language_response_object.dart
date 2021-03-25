import 'package:flutterclient/src/models/api/response_object.dart';

class LanguageResponseObject extends ResponseObject {
  final String language;
  final String languageResource;

  LanguageResponseObject(
      {required String name,
      required this.language,
      required this.languageResource})
      : super(name: name);

  LanguageResponseObject.fromJson({required Map<String, dynamic> map})
      : language = map['langCode'],
        languageResource = map['languageResource'],
        super.fromJson(map: map);
}
