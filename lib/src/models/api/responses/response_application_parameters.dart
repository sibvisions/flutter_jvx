import 'package:flutter_jvx/src/models/api/responses.dart';

class ResponseApplicationParameters extends ApiResponse {
   String? authenticated;
   String? openScreen;

   ResponseApplicationParameters.fromJson(Map<String, dynamic> json) :
      authenticated = json[_PApplicationParameters.authenticated],
      openScreen = json[_PApplicationParameters.openScreen],
      super.fromJson(json);


}


class _PApplicationParameters {
  static const authenticated = "authenticated";
  static const openScreen = "openScreen";
}