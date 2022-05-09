import 'package:flutter_client/src/model/command/api/api_command.dart';

class LogoutCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LogoutCommand({
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  // TODO: implement logString
  String get logString => throw UnimplementedError();
}
