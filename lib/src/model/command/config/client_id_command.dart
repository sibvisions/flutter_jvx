import 'package:flutter_client/src/model/command/config/config_command.dart';

class ClientIdCommand extends ConfigCommand {
  String? clientId;

  ClientIdCommand({
    this.clientId,
    required String reason
  }): super(reason: reason);
}