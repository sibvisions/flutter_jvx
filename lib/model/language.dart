class Language {
  String langCode;
  String name;
  String languageResource;

  Language({this.langCode, this.name, this.languageResource});

  Language.fromJson(Map<String, dynamic> json)
    : langCode = json['langCode'],
      name = json['name'],
      languageResource = json['languageResource'];
}