import 'package:flutter_client/src/model/command/api/api_command.dart';

class OpenScreenCommand extends ApiCommand {
  final String componentId;

  OpenScreenCommand({
    required this.componentId,
    required String reason,
  }) : super(reason: reason);
}