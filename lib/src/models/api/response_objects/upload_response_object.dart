import 'package:flutterclient/src/models/api/response_object.dart';

class UploadResponseObject extends ResponseObject {
  String filename;

  UploadResponseObject({required String name, required this.filename})
      : super(name: name);
}
