import '../response_object.dart';

class DownloadResponse extends ResponseObject {
  String fileName;
  dynamic download;

  DownloadResponse(this.fileName, this.download);
}
