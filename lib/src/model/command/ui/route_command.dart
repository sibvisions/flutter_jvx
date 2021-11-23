import 'package:flutter_client/src/model/command/ui/ui_command.dart';
import 'package:flutter_client/src/routing/app_routing_options.dart';

///
/// Issue this command to route to a new page.
///
class RouteCommand extends UiCommand {

  AppRoutingOptions routeTo;
  String? screenName;

  RouteCommand({
    this.screenName,
    required this.routeTo,
    required String reason,
  }) : super(reason: reason);
}