import 'package:flutter_client/src/model/command/ui/ui_command.dart';

/// Command to route to login
class RouteToLoginCommand extends UiCommand {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RouteToLoginCommand({
    required String reason,
  }) : super(reason:  reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => throw UnimplementedError();

}