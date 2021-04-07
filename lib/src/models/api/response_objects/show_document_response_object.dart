import 'package:flutterclient/src/models/api/response_object.dart';

class ShowDocumentResponseObject extends ResponseObject {
  String? document;
  String? bounds;
  String? target;

  ShowDocumentResponseObject.fromJson({required Map<String, dynamic> map})
      : super.fromJson(map: map) {
    String? url = map['url'];

    if (url != null) {
      List<String> urlParts = url.split(';');

      if (urlParts.isNotEmpty) {
        if (urlParts.length > 0) document = urlParts[0];
        if (urlParts.length > 1) bounds = urlParts[1];
        if (urlParts.length > 2) target = urlParts[2];
      }
    }
  }
}
