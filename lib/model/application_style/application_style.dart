class ApplicationStyle {
  String clientId;
  String name = "applicationStyle";
  String contentMode = "json";
  bool libraryImages = false;
  bool applicationImages = false;

  ApplicationStyle({this.clientId, this.name, this.contentMode});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'name': name,
    'contentMode': contentMode,
    'libraryImages': libraryImages,
    'applicationImages': applicationImages
  };
}