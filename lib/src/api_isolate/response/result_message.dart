import 'api_isolate_response.dart';

class ResultMessage extends ApiIsolateResponse {
  final bool success;
  final String message;

  ResultMessage({
    required this.success,
    required this.message,
    required String id}) : super(id: id);
}