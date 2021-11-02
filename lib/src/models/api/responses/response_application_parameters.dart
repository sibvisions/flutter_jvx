import 'package:flutter_jvx/src/models/api/responses.dart';

class ResponseApplicationParameters extends ApiResponse {
   String? authenticated;

   ResponseApplicationParameters.fromJson(Map<String, dynamic> json) :
      authenticated = json[_PApplicationParameters.authenticated],
      super.fromJson(json);


}


class _PApplicationParameters {
  static const authenticated = "authenticated";
}