import 'package:flutterclient/src/models/api/response_object.dart';

class DownloadResponseObject extends ResponseObject {
  final bool translation;

  DownloadResponseObject({required String name, required this.translation})
      : super(name: name);
}
