import 'package:flutterclient/src/models/api/request.dart';

class DownloadRequest extends Request {
  final String fileId;

  DownloadRequest({required String clientId, required this.fileId})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'fileId': fileId, ...super.toJson()};
}
