/// Model for the [Download] request.
class Download {
  String name;
  bool libraryImages;
  bool applicationImages;
  String clientId;

  Download({this.name, this.libraryImages, this.applicationImages, this.clientId});

  Map<String, dynamic> toJson() => {
    'name': name,
    'libraryImages': libraryImages,
    'applicationImages': applicationImages,
    'clientId': clientId
  };
}