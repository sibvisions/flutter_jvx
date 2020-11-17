import '../response_object.dart';

class ErrorResponse extends ResponseObject {
  final String title;
  final String details;
  final String message;

  ErrorResponse(this.title, this.details, this.message, String name)
      : super(name: name);

  ErrorResponse.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        details = json['details'],
        message = json['message'],
        super.fromJson(json);
}
