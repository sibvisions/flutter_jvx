class FileConfig {
  List<String> images = <String>[];
  Map<String, String> files = <String, String>{};

  FileConfig();

  bool hasImage(String image) {
    return images.contains(image);
  }
}
