import 'config_command.dart';

class ClientIdCommand extends ConfigCommand {
  String? clientId;

  ClientIdCommand({
    this.clientId,
    required String reason
  }): super(reason: reason);
}