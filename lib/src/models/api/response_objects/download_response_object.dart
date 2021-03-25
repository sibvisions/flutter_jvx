import 'dart:typed_data';

import 'package:flutterclient/src/models/api/response_object.dart';

class DownloadResponseObject extends ResponseObject {
  final bool translation;
  final Uint8List bodyBytes;

  DownloadResponseObject(
      {required String name,
      required this.translation,
      required this.bodyBytes})
      : super(name: name);
}
