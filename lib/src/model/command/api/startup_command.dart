import 'package:flutter_client/src/model/command/api/api_command.dart';

class StartupCommand extends ApiCommand {

  StartupCommand({
    required String reason,
  }) : super(reason: reason);
}