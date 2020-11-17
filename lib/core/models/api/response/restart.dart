import '../response_object.dart';

class Restart extends ResponseObject {
  String info;

  Restart({this.info});

  Restart.fromJson(Map<String, dynamic> json)
      : info = json['info'],
        super.fromJson(json);
}
