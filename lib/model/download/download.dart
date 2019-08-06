class ImageDownload {
  String name;
  bool libraryImages;
  bool applicationImages;
  String clientId;

  ImageDownload({this.name, this.libraryImages, this.applicationImages, this.clientId});

  Map<String, dynamic> toJson() => {
    'name': name,
    'libraryImages': libraryImages,
    'applicationImages': applicationImages,
    'clientId': clientId
  };
}