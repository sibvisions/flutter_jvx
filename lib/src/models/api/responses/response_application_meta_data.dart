

import 'api_response.dart';

class ResponseApplicationMetaData extends ApiResponse {
  String clientId;


  ResponseApplicationMetaData.fromJson(Map<String, dynamic> json) :
        clientId = json[_PApplicationMetaData.clientId],
        super.fromJson(json);

}

class _PApplicationMetaData {
  static const clientId = "clientId";
}