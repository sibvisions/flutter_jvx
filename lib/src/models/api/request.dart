import 'package:uuid/uuid.dart';

class Request {
  final String clientId;
  final String id;
  final String? debugInfo;
  final bool? reload;

  Request({required this.clientId, this.debugInfo, this.reload = false})
      : id = Uuid().v1();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'clientId': clientId,
      };
}
