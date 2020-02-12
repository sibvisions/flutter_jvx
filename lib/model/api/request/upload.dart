import 'dart:io';
import '../../../model/api/request/request.dart';

class Upload extends Request {
  String fileId;
  File file;

  Upload({this.fileId, this.file, String clientId, RequestType requestType}) : super(clientId: clientId, requestType: requestType);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'fileId': fileId,
    'clientId': clientId,
    'name': 'upload'
  };
}