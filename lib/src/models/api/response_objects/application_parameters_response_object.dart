import '../response_object.dart';

class ApplicationParametersResponseObject extends ResponseObject {
  Map<String, dynamic>? parameters;

  ApplicationParametersResponseObject.fromJson(
      {required Map<String, dynamic> map})
      : super.fromJson(map: map) {
    if (map.isNotEmpty) {
      parameters = <String, dynamic>{};

      map.forEach((key, value) {
        if (key != 'name') {
          parameters![key] = value;
        }
      });
    }
  }
}
