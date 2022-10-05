import 'ui_command.dart';

/// Command to route to the currently active workScreen
class RouteToWorkCommand extends UiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String screenName;

  /// 'True' if the route should replace the the current one in the stack
  final bool replaceRoute;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  RouteToWorkCommand({
    required this.screenName,
    this.replaceRoute = false,
    required super.reason,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Duration get loadingDelay => Duration.zero;

  @override
  String toString() {
    return "RouteToWorkCommand{screenName: $screenName, replaceRoute: $replaceRoute, ${super.toString()}}";
  }
}
