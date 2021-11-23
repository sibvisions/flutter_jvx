import 'package:flutter_client/src/model/command/base_command.dart';

class AuthenticatedCommand extends BaseCommand {
  bool authenticated;

  AuthenticatedCommand({
    required this.authenticated,
    required String reason
  }) : super(reason: reason);
}