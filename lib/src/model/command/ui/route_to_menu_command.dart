import 'package:flutter_client/src/model/command/ui/ui_command.dart';

/// Will Route to menu, may be ignored if other commands in a batch take routing
/// priority.
class RouteToMenuCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// 'True' if the route should replace the the current one in the stack
  final bool replaceRoute;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RouteToMenuCommand({
    this.replaceRoute = false,
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString => "RouteToMenuCommand: replaceRoute: $replaceRoute, reason: $reason";
}
