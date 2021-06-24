import 'package:flutterclient/src/models/api/request.dart';

class ResetPasswordRequest extends Request {
  final String identifier;

  ResetPasswordRequest({required String clientId, required this.identifier})
      : super(clientId: clientId);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'identifier': identifier, ...super.toJson()};
}
