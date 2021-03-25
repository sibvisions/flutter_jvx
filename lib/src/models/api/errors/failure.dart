import 'package:flutterclient/src/models/api/response_object.dart';

class Failure extends ResponseObject {
  final String? message;
  final String? details;
  final String? title;

  Failure(
      {required String name,
      required this.details,
      required this.message,
      required this.title})
      : super(name: name);

  Failure.fromJson({required Map<String, dynamic> map})
      : message = map['message'],
        details = map['details'],
        title = map['title'],
        super.fromJson(map: map);
}

class ServerFailure extends Failure {
  ServerFailure(
      {required String message,
      required String name,
      required String details,
      required String title})
      : super(message: message, title: title, name: name, details: details);

  ServerFailure.fromJson(Map<String, dynamic> map) : super.fromJson(map: map);
}

class CacheFailure extends Failure {
  CacheFailure(
      {required String message,
      required String name,
      required String details,
      required String title})
      : super(message: message, title: title, name: name, details: details);

  CacheFailure.fromJson(Map<String, dynamic> map) : super.fromJson(map: map);
}
